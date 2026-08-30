import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Token was rejected (401) — the caller should re-auth and retry once.
class MarketingAuthExpired implements Exception {
  @override
  String toString() => 'MarketingAuthExpired';
}

/// 403 — the signed-in user lacks the required HRMS permission. This can't be
/// fixed from the app; an HRMS admin must grant it.
class MarketingForbidden implements Exception {
  final String message;
  MarketingForbidden([this.message = _default]);
  static const _default =
      'Your HRMS account is missing the "marketing.create_visiting_card_contact" '
      'permission. Ask an HRMS administrator to grant it.';
  @override
  String toString() => 'MarketingForbidden: $message';
}

/// 422 — the payload failed server-side validation. [fieldErrors] holds the
/// per-field detail the API returned.
class MarketingValidationError implements Exception {
  final Map<String, dynamic> fieldErrors;
  final String summary;
  MarketingValidationError(this.fieldErrors, this.summary);
  @override
  String toString() => 'MarketingValidationError: $summary';
}

/// Transport failure or a retryable server error (5xx, connection refused, DNS).
/// The server definitely did NOT create the record — safe to keep queued and
/// auto-retry.
class MarketingRetryable implements Exception {
  final String message;
  MarketingRetryable(this.message);
  @override
  String toString() => 'MarketingRetryable: $message';
}

/// The request timed out AFTER being sent. The server has no dedup, so it may or
/// may not have created the card. Do NOT auto-retry — surface it for a manual,
/// deliberate retry.
class MarketingUncertain implements Exception {
  final String message;
  MarketingUncertain([this.message = 'Request timed out — the card may or may '
      'not have been saved. Check the office side before retrying.']);
  @override
  String toString() => 'MarketingUncertain: $message';
}

class MarketingClient {
  MarketingClient({http.Client? httpClient, String? baseUrl})
      : _http = httpClient ?? http.Client(),
        _baseUrl = _normalize(baseUrl ?? defaultBaseUrl);

  final http.Client _http;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 20);

  /// Marketing API origin. Defaults to the deployed instance; override for local
  /// dev with `--dart-define=MARKETING_API_BASE=http://<host>:8003`.
  static const defaultBaseUrl = String.fromEnvironment(
    'MARKETING_API_BASE',
    defaultValue: 'https://api-marketing.encryptedbar.com',
  );

  bool get isConfigured => _baseUrl.isNotEmpty;

  /// The resolved origin — handy for surfacing "couldn't reach ..." in the UI.
  String get baseUrl => _baseUrl;

  static String _normalize(String raw) {
    var b = raw.trim();
    while (b.endsWith('/')) {
      b = b.substring(0, b.length - 1);
    }
    return b;
  }

  /// POSTs one Visiting Card Contact. [token] is the HRMS JWT (sent as Bearer).
  /// Returns the created record (request fields + server-assigned id/metadata).
  Future<Map<String, dynamic>> createVisitingCardContact(
    Map<String, dynamic> body,
    String token,
  ) async {
    if (!isConfigured) {
      throw MarketingRetryable('MARKETING_API_BASE is not set');
    }

    final http.Response res;
    try {
      res = await _http
          .post(
            Uri.parse('$_baseUrl/api/visiting-card-contacts'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw MarketingUncertain();
    } catch (e) {
      throw MarketingRetryable('$e');
    }

    switch (res.statusCode) {
      case 200:
      case 201:
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is Map<String, dynamic>) return decoded;
        } catch (_) {}
        // Created but the body was unusable — treat as success with no echo.
        return const {};
      case 401:
        throw MarketingAuthExpired();
      case 403:
        throw MarketingForbidden(_extractDetail(res) ?? MarketingForbidden._default);
      case 400:
        // e.g. exhibition_id doesn't match a real event → the cached exhibition
        // is stale. Not retryable as-is.
        throw MarketingValidationError(
          _extractValidationErrors(res),
          _extractDetail(res) ?? 'Rejected (400) — the selected exhibition may no longer exist.',
        );
      case 422:
        final errors = _extractValidationErrors(res);
        throw MarketingValidationError(errors, _summarize(errors));
      default:
        if (res.statusCode >= 500) {
          throw MarketingRetryable('HTTP ${res.statusCode}');
        }
        throw MarketingValidationError(
          {'_': 'HTTP ${res.statusCode}: ${res.body}'},
          'Request rejected (HTTP ${res.statusCode})',
        );
    }
  }

  /// `GET /api/auth/scope` — the signed-in employee's domain/region. No body,
  /// no permission gate (won't 403 for a permission reason).
  Future<Map<String, dynamic>> getScope(String token) async {
    final res = await _get('/api/auth/scope', token);
    _guardRead(res, _forbiddenScope);
    final d = _decode(res);
    if (d is Map<String, dynamic>) return d;
    throw MarketingRetryable('Unexpected shape from /api/auth/scope');
  }

  /// `GET /api/exhibitions/active` — array of currently-active exhibitions
  /// across all domains. 403 here means the account lacks `marketing.view_events`.
  Future<List<Map<String, dynamic>>> getActiveExhibitions(String token) async {
    final res = await _get('/api/exhibitions/active', token);
    _guardRead(res, _forbiddenExhibitions);
    final d = _decode(res);

    // Accept a bare array or a common wrapper ({data|results|exhibitions: [...]}).
    List? list;
    if (d is List) {
      list = d;
    } else if (d is Map) {
      for (final k in ['data', 'results', 'exhibitions', 'items']) {
        if (d[k] is List) {
          list = d[k] as List;
          break;
        }
      }
    }
    if (list == null) {
      final snippet = res.body.length > 160 ? '${res.body.substring(0, 160)}…' : res.body;
      throw MarketingRetryable('Unexpected /api/exhibitions/active response: $snippet');
    }
    return list.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }

  static const _forbiddenScope =
      'Your HRMS account cannot read the marketing scope.';
  static const _forbiddenExhibitions =
      'Your HRMS account is missing the "marketing.view_events" permission. '
      'Ask an HRMS administrator to grant it.';

  void close() => _http.close();

  // ─── Internals ─────────────────────────────────────────────────────

  Future<http.Response> _get(String path, String token) async {
    if (!isConfigured) throw MarketingRetryable('MARKETING_API_BASE is not set');
    try {
      return await _http.get(
        Uri.parse('$_baseUrl$path'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      ).timeout(_timeout);
    } catch (e) {
      throw MarketingRetryable('$e');
    }
  }

  void _guardRead(http.Response res, String forbiddenMessage) {
    if (res.statusCode == 401) throw MarketingAuthExpired();
    if (res.statusCode == 403) {
      throw MarketingForbidden(_extractDetail(res) ?? forbiddenMessage);
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      // Anything else (incl. 5xx / 404) — let the caller retry later.
      throw MarketingRetryable('HTTP ${res.statusCode}');
    }
    if (res.body.trim().isEmpty) throw MarketingRetryable('Empty response');
  }

  dynamic _decode(http.Response res) {
    try {
      return jsonDecode(res.body);
    } catch (_) {
      throw MarketingRetryable('Non-JSON response');
    }
  }

  String? _extractDetail(http.Response res) {
    try {
      final d = jsonDecode(res.body);
      if (d is Map) {
        for (final k in ['detail', 'message', 'error']) {
          if (d[k] is String) return d[k] as String;
        }
      }
    } catch (_) {}
    return null;
  }

  Map<String, dynamic> _extractValidationErrors(http.Response res) {
    try {
      final d = jsonDecode(res.body);
      if (d is Map<String, dynamic>) {
        // DRF style: {"detail": {...}} or {field: [msgs]} at top level.
        if (d['detail'] is Map) return (d['detail'] as Map).cast<String, dynamic>();
        if (d['errors'] is Map) return (d['errors'] as Map).cast<String, dynamic>();
        return d;
      }
    } catch (_) {}
    return {'_': res.body};
  }

  String _summarize(Map<String, dynamic> errors) {
    if (errors.isEmpty) return 'Validation failed';
    return errors.entries
        .map((e) {
          final v = e.value;
          final msg = v is List ? v.join(', ') : '$v';
          return e.key == '_' ? msg : '${e.key}: $msg';
        })
        .join(' · ');
  }
}
