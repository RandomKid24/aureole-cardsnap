import 'dart:math';

import '../../core/models/contact.dart';
import '../../core/config/parser_config.dart';

class DuplicateDetector {
  DuplicateDetector._();

  static String _soundex(String name) {
    if (name.isEmpty) return '';
    final a = name.toUpperCase();
    final codes = <String, String>{
      'B': '1', 'F': '1', 'P': '1', 'V': '1',
      'C': '2', 'G': '2', 'J': '2', 'K': '2', 'Q': '2', 'S': '2', 'X': '2', 'Z': '2',
      'D': '3', 'T': '3',
      'L': '4',
      'M': '5', 'N': '5',
      'R': '6',
    };

    var result = a[0];
    var lastCode = codes[a[0]] ?? '0';

    for (int i = 1; i < a.length && result.length < 4; i++) {
      final code = codes[a[i]] ?? '0';
      if (code != '0' && code != lastCode) {
        result += code;
      }
      lastCode = code;
    }

    return result.padRight(4, '0').substring(0, 4);
  }

  static int _levenshtein(String a, String b) {
    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    for (int i = 0; i <= m; i++) { dp[i][0] = i; }
    for (int j = 0; j <= n; j++) { dp[0][j] = j; }
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        dp[i][j] = a[i - 1] == b[j - 1]
            ? dp[i - 1][j - 1]
            : 1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].reduce(min);
      }
    }
    return dp[m][n];
  }

  /// Reduce a phone number to its last 9 significant digits so that
  /// "+91 98765 43210", "098765 43210" and "9876543210" all compare equal,
  /// regardless of country. Numbers shorter than 7 digits are treated as junk.
  static String _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return '';
    return digits.length <= 9 ? digits : digits.substring(digits.length - 9);
  }

  static String _normalizeEmail(String email) => email.toLowerCase().trim();

  static String _normalizeCompany(String company) {
    return company.toLowerCase()
        .replaceAll(RegExp(r'\b(pvt|ltd|llp|llc|inc|corp|co|company)\b\.?', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _normalizeWebsite(String url) {
    return url.toLowerCase()
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'^www\.'), '')
        .replaceAll(RegExp(r'/+$'), '')
        .trim();
  }

  static final _titlePattern = RegExp(
    r'^(Dr\.?|Mr\.?|Mrs\.?|Ms\.?|Prof\.?|Eng\.?)\s+',
    caseSensitive: false,
  );
  static final _suffixPattern = RegExp(
    r'\s+(Jr\.?|Sr\.?|II|III|IV|PhD|MD|MBA)$',
    caseSensitive: false,
  );

  static String _normalizeName(String name) => name
      .replaceAll(_titlePattern, '')
      .replaceAll(_suffixPattern, '')
      .trim()
      .toLowerCase();

  static Contact? findDuplicate(Map<String, dynamic> args) {
    final String name = args['name'];
    final List<String> phones = args['phones'];
    final List<String> emails = args['emails'];
    final String? company = args['company'];
    final String? website = args['website'];
    final List<Contact> contacts = args['contacts'];

    final normalizedPhones = phones.map(_normalizePhone).where((p) => p.isNotEmpty).toSet();
    final normalizedEmails = emails.map(_normalizeEmail).where((e) => e.isNotEmpty).toSet();
    final normName = _normalizeName(name);
    final nameSoundex = _soundex(normName);

    for (final c in contacts) {
      // --- Strong signals: a shared phone or email is a duplicate on its own ---
      final existingPhones = c.phones.map(_normalizePhone).where((p) => p.isNotEmpty).toSet();
      if (normalizedPhones.intersection(existingPhones).isNotEmpty) return c;

      final existingEmails = c.emails.map(_normalizeEmail).where((e) => e.isNotEmpty).toSet();
      if (normalizedEmails.intersection(existingEmails).isNotEmpty) return c;

      // --- Weak signals: a matching name only counts with corroboration ---
      // (otherwise two coworkers, or two "John"s, collapse into one).
      if (normName.isEmpty) continue;

      final cNormName = _normalizeName(c.name);
      final nameClose = cNormName.isNotEmpty &&
          (_levenshtein(normName, cNormName) <= ParserConfig.levenshteinThreshold ||
              (nameSoundex != '0000' && _soundex(cNormName) == nameSoundex));
      if (!nameClose) continue;

      final companyMatches = company != null &&
          c.company != null &&
          _companySimilar(company, c.company!);
      final websiteMatches = website != null &&
          c.website != null &&
          _normalizeWebsite(website) == _normalizeWebsite(c.website!);

      if (companyMatches || websiteMatches) return c;
    }
    return null;
  }

  static bool _companySimilar(String a, String b) {
    final n1 = _normalizeCompany(a);
    final n2 = _normalizeCompany(b);
    if (n1.isEmpty || n2.isEmpty) return false;
    if (n1 == n2) return true;
    final maxLen = max(n1.length, n2.length);
    return maxLen > 3 && _levenshtein(n1, n2) <= 2;
  }
}
