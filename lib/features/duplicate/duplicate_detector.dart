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

  static String _normalizePhone(String phone) =>
      phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '')
          .replaceAll(RegExp(r'^91'), '')
          .replaceAll(RegExp(r'^0'), '');

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

    final normalizedPhones = phones.map(_normalizePhone).toSet();
    final normalizedEmails = emails.map(_normalizeEmail).toSet();
    final nameSoundex = _soundex(_normalizeName(name));

    for (final c in contacts) {
      // Phone match
      final existingPhones = c.phones.map(_normalizePhone).toSet();
      if (normalizedPhones.intersection(existingPhones).isNotEmpty) return c;

      // Email match
      final existingEmails = c.emails.map(_normalizeEmail).toSet();
      if (normalizedEmails.intersection(existingEmails).isNotEmpty) return c;

      // Name: Levenshtein distance
      if (name.isNotEmpty) {
        final dist = _levenshtein(_normalizeName(name), _normalizeName(c.name));
        if (dist <= ParserConfig.levenshteinThreshold) return c;
      }

      // Name: Soundex match
      if (name.isNotEmpty) {
        final cSoundex = _soundex(_normalizeName(c.name));
        if (nameSoundex == cSoundex && nameSoundex != '0000') return c;
      }

      // Company similarity
      if (company != null && c.company != null) {
        final norm1 = _normalizeCompany(company);
        final norm2 = _normalizeCompany(c.company!);
        if (norm1.isNotEmpty && norm2.isNotEmpty) {
          if (norm1 == norm2) return c;
          final companyDist = _levenshtein(norm1, norm2);
          final maxLen = [norm1.length, norm2.length].reduce(max);
          if (maxLen > 3 && companyDist <= 2) return c;
        }
      }

      // Website similarity
      if (website != null && c.website != null) {
        final norm1 = _normalizeWebsite(website);
        final norm2 = _normalizeWebsite(c.website!);
        if (norm1 == norm2) return c;
      }
    }
    return null;
  }
}
