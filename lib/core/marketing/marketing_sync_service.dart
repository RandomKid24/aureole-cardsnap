import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_service.dart';
import '../database/database.dart';
import '../models/contact.dart' as model;
import 'marketing_client.dart';
import 'marketing_models.dart';

class MarketingFailure {
  final int queueId;
  final String contactName;
  final String error;
  MarketingFailure(this.queueId, this.contactName, this.error);
}

/// Pushes saved contacts to the Marketing API as "Visiting Card Contacts".
///
/// Design: a durable outbox (the `marketing_sync_queue` table). [enqueue] never
/// blocks the capture flow — it writes a row and kicks a background [flush].
/// Network / server hiccups leave the row pending for a later retry; permission
/// (403) and validation (422) errors mark it `failed` and are surfaced in
/// Settings.
class MarketingSyncService extends ChangeNotifier {
  MarketingSyncService({
    required AppDatabase db,
    required AuthService auth,
    MarketingClient? client,
    SharedPreferences? prefs,
  })  : _db = db,
        _auth = auth,
        _client = client ?? MarketingClient(),
        _prefs = prefs {
    _auth.addListener(_onAuthChanged);
    _loadActiveExhibition();
  }

  static const source = 'card-scanner-app';
  static const _maxAttempts = 5;

  final AppDatabase _db;
  final AuthService _auth;
  final MarketingClient _client;

  bool _flushing = false;
  int _pendingCount = 0;
  List<MarketingFailure> _failures = const [];

  // Reference data for the "save this card" screen.
  static const _exhibitionsTtl = Duration(minutes: 10);
  MarketingScope? _scope;
  List<Exhibition> _exhibitions = const [];
  DateTime? _exhibitionsFetchedAt;

  MarketingScope? get scope => _scope;

  // The exhibition the user says they're currently at. Set from the main
  // screen; every new capture defaults to it. Persisted across restarts.
  static const _kActiveExhibition = 'marketing_active_exhibition';
  SharedPreferences? _prefs;
  Exhibition? _activeExhibition;

  Exhibition? get activeExhibition => _activeExhibition;

  Future<void> _loadActiveExhibition() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final raw = _prefs?.getString(_kActiveExhibition);
      if (raw != null && raw.isNotEmpty) {
        _activeExhibition =
            Exhibition.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('MarketingSync: could not load active exhibition: $e');
    }
  }

  Future<void> setActiveExhibition(Exhibition? e) async {
    _activeExhibition = e;
    notifyListeners();
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (e == null) {
        await _prefs!.remove(_kActiveExhibition);
      } else {
        await _prefs!.setString(_kActiveExhibition, jsonEncode(e.toJson()));
      }
    } catch (err) {
      debugPrint('MarketingSync: could not persist active exhibition: $err');
    }
  }

  bool get isConfigured => _client.isConfigured;
  int get pendingCount => _pendingCount;
  int get failedCount => _failures.length;
  List<MarketingFailure> get failures => _failures;

  void _onAuthChanged() {
    if (_auth.isAuthenticated) unawaited(flush());
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _client.close();
    super.dispose();
  }

  // ─── Public API ────────────────────────────────────────────────────

  /// Queue a contact for the Marketing API. Returns immediately.
  Future<void> enqueue(model.Contact c) async {
    if (!_client.isConfigured) return;
    if (c.marketingContactId != null) return; // already pushed
    try {
      await _db.into(_db.marketingSyncQueue).insert(
            MarketingSyncQueueCompanion.insert(
              payloadJson: jsonEncode(buildPayload(c)),
              createdAt: DateTime.now(),
              contactId: Value(c.id),
              contactName: Value(c.name),
            ),
          );
    } catch (e) {
      debugPrint('MarketingSync: failed to enqueue ${c.id}: $e');
      return;
    }
    await _refreshCounts();
    unawaited(flush());
  }

  /// Retry every `failed` row.
  Future<void> retryFailed() async {
    await (_db.update(_db.marketingSyncQueue)..where((t) => t.status.equals('failed')))
        .write(const MarketingSyncQueueCompanion(
      status: Value('pending'),
      lastError: Value(null),
      attempts: Value(0),
    ));
    await _refreshCounts();
    await flush();
  }

  /// Permanently drop a failed row (user gave up on it).
  Future<void> discard(int queueId) async {
    await (_db.delete(_db.marketingSyncQueue)..where((t) => t.id.equals(queueId))).go();
    await _refreshCounts();
  }

  /// Process the outbox. Safe to call any time; no-ops if already running.
  Future<void> flush() async {
    if (_flushing || !_client.isConfigured) return;
    if (!_auth.isAuthenticated) return;
    _flushing = true;
    try {
      while (true) {
        final row = await (_db.select(_db.marketingSyncQueue)
              ..where((t) => t.status.equals('pending'))
              ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
        if (row == null) break;
        final stop = await _process(row);
        if (stop) break;
      }
    } finally {
      _flushing = false;
      await _refreshCounts();
    }
  }

  // ─── Reference data (save screen) ──────────────────────────────────

  /// Loads the employee's marketing scope + the active-exhibitions list.
  /// Exhibitions are cached for [_exhibitionsTtl]; pass [forceRefresh] to bypass.
  Future<MarketingCaptureContext> loadCaptureContext({bool forceRefresh = false}) async {
    final base = _client.baseUrl;
    if (!_client.isConfigured) {
      return const MarketingCaptureContext(
          exhibitionsError: 'MARKETING_API_BASE is not set on this build.');
    }
    if (!_auth.isAuthenticated) {
      return MarketingCaptureContext(scope: _scope, exhibitions: _exhibitions);
    }

    if (_scope == null || forceRefresh) {
      try {
        final m = await _withReauth((t) => _client.getScope(t));
        if (m != null) _scope = MarketingScope.fromJson(m);
      } catch (e) {
        debugPrint('MarketingSync: scope fetch failed: $e');
      }
    }

    String? exhibitionsError;
    final fresh = _exhibitionsFetchedAt != null &&
        DateTime.now().difference(_exhibitionsFetchedAt!) < _exhibitionsTtl;
    if (!fresh || forceRefresh || _exhibitions.isEmpty) {
      try {
        final raw = await _withReauth((t) => _client.getActiveExhibitions(t));
        if (raw != null) {
          _exhibitions = raw.map(Exhibition.fromJson).toList();
          _exhibitionsFetchedAt = DateTime.now();
        } else {
          exhibitionsError = 'Session expired — sign in again.';
        }
      } on MarketingForbidden catch (e) {
        exhibitionsError = e.message;
      } on MarketingValidationError catch (e) {
        exhibitionsError = e.summary;
      } on MarketingRetryable catch (e) {
        exhibitionsError = "Couldn't load exhibitions from $base — ${e.message}";
        debugPrint('MarketingSync: exhibitions fetch failed: $e');
      } catch (e) {
        exhibitionsError = "Couldn't load exhibitions from $base ($e)";
        debugPrint('MarketingSync: exhibitions fetch failed: $e');
      }
    }

    return MarketingCaptureContext(
      scope: _scope,
      exhibitions: _exhibitions,
      exhibitionsError: exhibitionsError,
    );
  }

  /// The resolved Marketing base URL (for diagnostics in the UI).
  String get baseUrl => _client.baseUrl;

  /// Runs an authed call; on 401, revalidates the token once and retries.
  /// Returns null if the session is dead (app will drop to the login screen).
  Future<T?> _withReauth<T>(Future<T> Function(String token) call) async {
    final t = _auth.token;
    if (t == null) return null;
    try {
      return await call(t);
    } on MarketingAuthExpired {
      if (!await _auth.revalidate()) return null;
      final t2 = _auth.token;
      return t2 == null ? null : await call(t2);
    }
  }

  // ─── Payload ───────────────────────────────────────────────────────

  static String? _nn(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();

  /// The API has no exhibition field (internal Marketing IDs are intentionally
  /// excluded), so the picked exhibition is carried in `notes` as plain text for
  /// the marketing user who later converts the record.
  static String? _notesWithExhibition(model.Contact c) {
    final base = _nn(c.notes);
    final ex = _nn(c.exhibitionName);
    if (ex == null) return base;
    final line = 'Exhibition: $ex';
    return base == null ? line : '$line\n\n$base';
  }

  static Map<String, dynamic> buildPayload(model.Contact c) => {
        'name': _nn(c.name),
        'company_name': _nn(c.company),
        'designation': _nn(c.designation),
        'phone_numbers': c.phones.where((p) => p.trim().isNotEmpty).toList(),
        'emails': c.emails.where((e) => e.trim().isNotEmpty).toList(),
        'website': _nn(c.website),
        'social_media': [c.linkedInUrl, c.twitterHandle]
            .where((s) => s != null && s.trim().isNotEmpty)
            .map((s) => s!.trim())
            .toList(),
        'address': _nn(c.address),
        'notes': _notesWithExhibition(c),
        'source': source,
      };

  // ─── Internals ─────────────────────────────────────────────────────

  /// Returns true if the flush loop should stop (transient failure / no auth).
  Future<bool> _process(MarketingSyncQueueData row, {bool reauthed = false}) async {
    final token = _auth.token;
    if (token == null) return true;

    try {
      final resp = await _client.createVisitingCardContact(
        jsonDecode(row.payloadJson) as Map<String, dynamic>,
        token,
      );
      final id = resp['id'];
      if (row.contactId != null && id is int) {
        await _db.contactsDao.setMarketingContactId(row.contactId!, id);
      }
      await (_db.delete(_db.marketingSyncQueue)..where((r) => r.id.equals(row.id))).go();
      return false;
    } on MarketingAuthExpired {
      if (reauthed) {
        await _bumpAttempts(row);
        return true; // already retried once — give the queue a break
      }
      final stillValid = await _auth.revalidate();
      if (!stillValid) return true; // session cleared → login screen; row stays pending
      return _process(row, reauthed: true); // retry once with the (re-checked) token
    } on MarketingForbidden catch (e) {
      // Everyone in the queue will hit the same wall — fail them all with the
      // one message so Settings can show it once.
      await (_db.update(_db.marketingSyncQueue)..where((t) => t.status.equals('pending')))
          .write(MarketingSyncQueueCompanion(
        status: const Value('failed'),
        lastError: Value(e.message),
      ));
      return true;
    } on MarketingValidationError catch (e) {
      debugPrint('MarketingSync: 422 for "${row.contactName}": ${e.fieldErrors}');
      await _markFailed(row, e.summary);
      return false; // other rows may still be valid
    } on MarketingRetryable catch (e) {
      debugPrint('MarketingSync: retryable for "${row.contactName}": $e');
      await _bumpAttempts(row);
      return true; // network/server problem — stop, retry the whole queue later
    }
  }

  Future<void> _markFailed(MarketingSyncQueueData row, String error) async {
    await (_db.update(_db.marketingSyncQueue)..where((t) => t.id.equals(row.id)))
        .write(MarketingSyncQueueCompanion(
      status: const Value('failed'),
      lastError: Value(error),
    ));
  }

  Future<void> _bumpAttempts(MarketingSyncQueueData row) async {
    final n = row.attempts + 1;
    if (n >= _maxAttempts) {
      await _markFailed(row, 'Gave up after $n attempts — ${row.lastError ?? "network/server error"}');
    } else {
      await (_db.update(_db.marketingSyncQueue)..where((t) => t.id.equals(row.id)))
          .write(MarketingSyncQueueCompanion(attempts: Value(n)));
    }
  }

  Future<void> _refreshCounts() async {
    try {
      final rows = await _db.select(_db.marketingSyncQueue).get();
      _pendingCount = rows.where((r) => r.status == 'pending').length;
      _failures = rows
          .where((r) => r.status == 'failed')
          .map((r) => MarketingFailure(
              r.id, r.contactName.isEmpty ? 'Contact' : r.contactName, r.lastError ?? 'Failed'))
          .toList();
    } catch (e) {
      debugPrint('MarketingSync: count refresh failed: $e');
    }
    notifyListeners();
  }
}
