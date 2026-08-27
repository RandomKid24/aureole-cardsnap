import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when the RBAC API says (or strongly implies) the caller is not
/// authorized — a 401/403, an empty body, malformed JSON, `success: false`, or
/// any response that doesn't look the way a valid one should. Per the API's
/// quirks we do NOT trust a 200 alone.
class RbacUnauthorized implements Exception {
  final String message;
  RbacUnauthorized(this.message);
  @override
  String toString() => 'RbacUnauthorized: $message';
}

/// Thrown for transport failures (no network, DNS, timeout). Distinct from
/// [RbacUnauthorized] so callers can stay in an offline/last-known state instead
/// of forcing a logout.
class RbacNetworkError implements Exception {
  final String message;
  RbacNetworkError(this.message);
  @override
  String toString() => 'RbacNetworkError: $message';
}

class RbacLoginResult {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic> employee;
  final List<dynamic> roles;
  final List<String> permissions;

  RbacLoginResult({
    required this.token,
    required this.user,
    required this.employee,
    required this.roles,
    required this.permissions,
  });
}

class RbacClient {
  RbacClient({http.Client? httpClient, String? baseUrl})
      : _http = httpClient ?? http.Client(),
        _baseUrl = _normalizeBase(baseUrl ?? defaultBaseUrl);

  final http.Client _http;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 20);

  /// HRMS origin. Override at build time with
  /// `--dart-define=HRMS_BASE_URL=https://hrms.example.com`.
  static const defaultBaseUrl = String.fromEnvironment(
    'HRMS_BASE_URL',
    defaultValue: 'https://hrms.encryptedbar.com',
  );

  static String _normalizeBase(String raw) {
    var b = raw.trim();
    while (b.endsWith('/')) {
      b = b.substring(0, b.length - 1);
    }
    return b;
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl/api/rbac/$path');

  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Token $token',
      };

  // ─── Endpoints ─────────────────────────────────────────────────────

  Future<RbacLoginResult> login(String username, String password) async {
    final http.Response res;
    try {
      res = await _http
          .post(
            _uri('login/'),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(_timeout);
    } catch (e) {
      throw RbacNetworkError('$e');
    }

    if (res.statusCode == 401 || res.statusCode == 403) {
      throw RbacUnauthorized(_errorFrom(res) ?? 'Invalid username or password');
    }
    if (res.statusCode != 200) {
      throw RbacUnauthorized('Login failed (HTTP ${res.statusCode})');
    }

    final body = _decodeObject(res);
    if (body['success'] != true) {
      throw RbacUnauthorized(_stringOr(body['error'], 'Login was rejected'));
    }
    final token = body['token'];
    if (token is! String || token.isEmpty) {
      throw RbacUnauthorized('Login response did not include a token');
    }

    return RbacLoginResult(
      token: token,
      user: _asMap(body['user']),
      employee: _asMap(body['employee']),
      roles: _asList(body['roles']),
      permissions: _permissionCodes(body['permissions']),
    );
  }

  /// Flat list of permission codes for the current token. Also serves as a
  /// token-validity probe on app start.
  Future<List<String>> permissionsList(String token) async {
    final body = await _getRaw('user/permissions/list/', token);
    // Endpoint returns a bare JSON array of strings.
    if (body is List) return _permissionCodes(body);
    if (body is Map && body['permissions'] is List) {
      return _permissionCodes(body['permissions']);
    }
    throw RbacUnauthorized('Unexpected shape from permissions/list');
  }

  Future<List<dynamic>> roles(String token) async {
    final body = await _getRaw('user/roles/', token);
    if (body is List) return body;
    if (body is Map && body['roles'] is List) return body['roles'] as List;
    throw RbacUnauthorized('Unexpected shape from user/roles');
  }

  Future<bool> checkPermission(String token, String code) async {
    final http.Response res;
    try {
      res = await _http
          .post(_uri('check-permission/'),
              headers: _authHeaders(token), body: jsonEncode({'permission_code': code}))
          .timeout(_timeout);
    } catch (e) {
      throw RbacNetworkError('$e');
    }
    _guardStatus(res);
    final body = _decodeObject(res);
    final v = body['has_permission'] ?? body['result'] ?? body['allowed'];
    if (v is bool) return v;
    throw RbacUnauthorized('check-permission returned no boolean');
  }

  /// Best-effort — always clear local state regardless of the outcome.
  Future<void> logout(String token) async {
    try {
      await _http
          .post(_uri('logout/'), headers: _authHeaders(token))
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // ignore — the caller drops the token anyway
    }
  }

  void close() => _http.close();

  // ─── Internals ─────────────────────────────────────────────────────

  Future<dynamic> _getRaw(String path, String token) async {
    final http.Response res;
    try {
      res = await _http.get(_uri(path), headers: _authHeaders(token)).timeout(_timeout);
    } catch (e) {
      throw RbacNetworkError('$e');
    }
    _guardStatus(res);
    if (res.body.trim().isEmpty) {
      throw RbacUnauthorized('Empty response from $path');
    }
    try {
      return jsonDecode(res.body);
    } catch (_) {
      throw RbacUnauthorized('Non-JSON response from $path');
    }
  }

  void _guardStatus(http.Response res) {
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw RbacUnauthorized(_errorFrom(res) ?? 'Session is no longer valid');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      // Not a 401, but the API is loose about auth checks — treat anything
      // unexpected as unauthorized rather than assuming the session is fine.
      throw RbacUnauthorized('Unexpected HTTP ${res.statusCode}');
    }
  }

  Map<String, dynamic> _decodeObject(http.Response res) {
    if (res.body.trim().isEmpty) throw RbacUnauthorized('Empty response body');
    final Object? decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      throw RbacUnauthorized('Response was not valid JSON');
    }
    if (decoded is! Map<String, dynamic>) {
      throw RbacUnauthorized('Response was not a JSON object');
    }
    return decoded;
  }

  String? _errorFrom(http.Response res) {
    try {
      final d = jsonDecode(res.body);
      if (d is Map && d['error'] is String) return d['error'] as String;
      if (d is Map && d['detail'] is String) return d['detail'] as String;
    } catch (_) {}
    return null;
  }

  static Map<String, dynamic> _asMap(dynamic v) =>
      v is Map<String, dynamic> ? v : <String, dynamic>{};

  static List<dynamic> _asList(dynamic v) => v is List ? v : const [];

  static String _stringOr(dynamic v, String fallback) =>
      v is String && v.isNotEmpty ? v : fallback;

  static List<String> _permissionCodes(dynamic v) {
    if (v is! List) return const [];
    return v
        .map((e) {
          if (e is String) return e;
          if (e is Map && e['code'] is String) return e['code'] as String;
          if (e is Map && e['permission_code'] is String) return e['permission_code'] as String;
          return '';
        })
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }
}
