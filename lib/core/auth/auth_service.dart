import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'rbac_client.dart';

/// Minimal key/value store so [AuthService] can be tested without the platform
/// secure-storage plugin.
abstract class SessionStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage])
      : _s = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;
  static const _key = 'hrms_rbac_session';

  @override
  Future<String?> read() => _s.read(key: _key);
  @override
  Future<void> write(String value) => _s.write(key: _key, value: value);
  @override
  Future<void> delete() => _s.delete(key: _key);
}

enum AuthStatus {
  /// Startup — haven't decided yet (show a splash).
  unknown,

  /// Have a token and it looked valid on last check.
  authenticated,

  /// No token, or the token was rejected — show the login screen.
  unauthenticated,
}

/// Everything the app knows about the signed-in user.
@immutable
class RbacSession {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic> employee;
  final List<dynamic> roles;
  final Set<String> permissions;

  const RbacSession({
    required this.token,
    required this.user,
    required this.employee,
    required this.roles,
    required this.permissions,
  });

  String get displayName {
    for (final k in ['full_name', 'name', 'first_name', 'username']) {
      final v = user[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    final v = employee['name'] ?? employee['full_name'];
    if (v is String && v.trim().isNotEmpty) return v.trim();
    return 'Signed in';
  }

  String? get subtitle {
    final id = employee['employee_id'] ?? employee['emp_id'] ?? user['username'];
    return id is String && id.isNotEmpty ? id : null;
  }

  Map<String, dynamic> _toCache() => {
        'token': token,
        'user': user,
        'employee': employee,
        'roles': roles,
        'permissions': permissions.toList(),
      };

  static RbacSession? _fromCache(Map<String, dynamic> m) {
    final token = m['token'];
    if (token is! String || token.isEmpty) return null;
    return RbacSession(
      token: token,
      user: (m['user'] as Map?)?.cast<String, dynamic>() ?? const {},
      employee: (m['employee'] as Map?)?.cast<String, dynamic>() ?? const {},
      roles: (m['roles'] as List?) ?? const [],
      permissions: ((m['permissions'] as List?) ?? const [])
          .whereType<String>()
          .toSet(),
    );
  }
}

/// Owns the HRMS/RBAC session: login, token persistence, permission lookups.
class AuthService extends ChangeNotifier {
  AuthService({RbacClient? client, SessionStore? store})
      : _client = client ?? RbacClient(),
        _store = store ?? SecureSessionStore();

  final RbacClient _client;
  final SessionStore _store;

  AuthStatus _status = AuthStatus.unknown;
  RbacSession? _session;

  /// True when the last server check failed for network reasons and we're
  /// running on a cached session.
  bool _offline = false;

  AuthStatus get status => _status;
  RbacSession? get session => _session;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _session != null;
  bool get isOffline => _offline;

  String? get token => _session?.token;

  /// Full-access model: any signed-in user can use everything. Permissions are
  /// still tracked so screens can tighten later without re-plumbing.
  bool hasPermission(String code) => _session?.permissions.contains(code) ?? false;
  Set<String> get permissions => _session?.permissions ?? const {};

  // ─── Lifecycle ─────────────────────────────────────────────────────

  /// Called once on app start. Loads any cached session, then revalidates the
  /// token against the server.
  Future<void> restore() async {
    RbacSession? cached;
    try {
      final raw = await _store.read();
      if (raw != null && raw.isNotEmpty) {
        cached = RbacSession._fromCache(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('AuthService: could not read cached session: $e');
    }

    if (cached == null) {
      _set(AuthStatus.unauthenticated, null);
      return;
    }

    // Optimistically show the app on the cached session, then verify.
    _session = cached;
    _status = AuthStatus.authenticated;
    notifyListeners();

    try {
      final perms = await _client.permissionsList(cached.token);
      List<dynamic> roles = cached.roles;
      try {
        roles = await _client.roles(cached.token);
      } catch (_) {
        // roles are non-critical; keep cached
      }
      final refreshed = RbacSession(
        token: cached.token,
        user: cached.user,
        employee: cached.employee,
        roles: roles,
        permissions: perms.toSet(),
      );
      _offline = false;
      await _persist(refreshed);
      _set(AuthStatus.authenticated, refreshed);
    } on RbacNetworkError catch (e) {
      // Can't reach the server — stay on the cached session, flag offline.
      debugPrint('AuthService: offline, using cached session ($e)');
      _offline = true;
      _set(AuthStatus.authenticated, cached);
    } on RbacUnauthorized catch (e) {
      debugPrint('AuthService: cached token rejected ($e)');
      await _clear();
      _set(AuthStatus.unauthenticated, null);
    } catch (e) {
      // Any other/unexpected failure → do not assume the session is fine.
      debugPrint('AuthService: unexpected error validating session ($e)');
      await _clear();
      _set(AuthStatus.unauthenticated, null);
    }
  }

  /// Returns null on success, or a user-facing error string.
  Future<String?> login(String username, String password) async {
    try {
      final r = await _client.login(username.trim(), password);
      final session = RbacSession(
        token: r.token,
        user: r.user,
        employee: r.employee,
        roles: r.roles,
        permissions: r.permissions.toSet(),
      );
      _offline = false;
      await _persist(session);
      _set(AuthStatus.authenticated, session);
      return null;
    } on RbacUnauthorized catch (e) {
      return e.message;
    } on RbacNetworkError {
      return "Can't reach the server. Check your connection and try again.";
    } catch (e) {
      debugPrint('AuthService: login error $e');
      return 'Login failed. Please try again.';
    }
  }

  Future<void> logout() async {
    final t = _session?.token;
    _offline = false;
    await _clear();
    _set(AuthStatus.unauthenticated, null);
    if (t != null) {
      // Fire-and-forget; the local session is already gone.
      unawaited(_client.logout(t));
    }
  }

  // ─── Storage ───────────────────────────────────────────────────────

  Future<void> _persist(RbacSession s) async {
    try {
      await _store.write(jsonEncode(s._toCache()));
    } catch (e) {
      debugPrint('AuthService: failed to persist session: $e');
    }
  }

  Future<void> _clear() async {
    try {
      await _store.delete();
    } catch (e) {
      debugPrint('AuthService: failed to clear session: $e');
    }
  }

  void _set(AuthStatus s, RbacSession? session) {
    _status = s;
    _session = session;
    notifyListeners();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
