import 'dart:math';

import '../scan/ocr_service.dart';
import '../../core/models/parse_result.dart';
import '../../core/config/parser_config.dart';
import '../../core/utils/calling_codes.dart';

class _CompanyCandidate {
  final OcrBlock block;
  final bool hasStrongSuffix;
  final bool hasWeakSuffix;
  final double fontSizeScore;
  final double positionScore;
  double compositeScore;

  _CompanyCandidate({
    required this.block,
    required this.hasStrongSuffix,
    required this.hasWeakSuffix,
    required this.fontSizeScore,
    required this.positionScore,
    this.compositeScore = 0.0,
  });
}

class LocalParser {
  /// Strong suffixes = legal entity indicators → 0.50 floor score
  static const List<String> _strongCompanySuffixes = [
    'Pvt Ltd', 'Private Limited', 'Ltd', 'LLP', 'LLC', 'Inc',
    'Corporation', 'Corp', 'Co', 'Company',
    'Group', 'Holdings', 'Enterprises',
    'Foundation', 'Trust', 'Institute', 'Academy',
    'Partners', 'Associates', 'Services', 'Manufacturing',
  ];

  /// Weak suffixes = industry descriptors → only 0.08 bonus (not a floor)
  static const List<String> _weakCompanySuffixes = [
    'Technologies', 'Technology', 'Solutions', 'Systems',
    'Consulting', 'Labs', 'Studio', 'Agency',
    'Digital', 'Tech', 'Software', 'Global', 'International',
    'Ventures', 'Capital', 'Advisors',
    'Hospitality', 'Industries', 'Media', 'Networks',
    'Point', 'Hub', 'Center', 'Centre',
    'Mart', 'Store', 'Shop', 'Retail', 'Trading', 'Traders',
    'Exports', 'Imports', 'Supply', 'Supplies',
  ];

  /// Words commonly found in taglines/slogans — penalize blocks containing these
  static final RegExp _sloganPattern = RegExp(
    r'\b(empowering|innovating|inspiring|transforming|delivering|enabling|driving|building|creating|shaping|redefining|your|our|the|we|one stop|all in one|beyond|future|together|quality|excellence|trust|passion|commitment|solution|partner|growth|smart|simple|fast|better|best|first|only)\b',
    caseSensitive: false,
  );

  final List<String> designationKeywords;

  /// Street-type / address-line keywords (international, no place names).
  final List<String> addressSignals;

  /// E.164 calling code (digits, no '+') used to expand a bare national phone
  /// number. Derived from [region] (device locale country); null when the
  /// region is unknown — in that case numbers are left in national format
  /// rather than guessing a country.
  final String? _defaultCallingCode;

  LocalParser({
    List<String>? designations,
    List<String>? addresses,
    String? region,
  })  : designationKeywords = designations ?? _fallbackDesignations,
        addressSignals = addresses ?? _fallbackAddresses,
        _defaultCallingCode = callingCodeForRegion(region);

  /// Postal / ZIP code shapes across common formats (US ZIP / ZIP+4, UK, Canada,
  /// India PIN, and the generic 4–6 digit block used by most other countries).
  static final List<RegExp> _postalCodePatterns = [
    RegExp(r'\b[A-Z]{1,2}\d[A-Z\d]?\s*\d[A-Z]{2}\b', caseSensitive: false), // UK
    RegExp(r'\b[A-Z]\d[A-Z]\s*\d[A-Z]\d\b', caseSensitive: false), // Canada
    RegExp(r'\b\d{5}-\d{4}\b'), // US ZIP+4
    RegExp(r'\b\d{4,6}\b'), // US ZIP, India PIN, EU/AU/other
  ];

  /// Patterns that indicate a block is NOT a person's name.
  static final List<RegExp> nonNamePatterns = [
    RegExp(r'https?://', caseSensitive: false),
    RegExp(r'www\.', caseSensitive: false),
    RegExp(r'@', caseSensitive: false),
    RegExp(r'\.com|\.org|\.net|\.io|\.co', caseSensitive: false),
    RegExp(r'^\+?\d[\d\s\-()]+$'),  // pure phone number
    RegExp(r'^\d{1,5}\s'),  // starts with street number
  ];

  ParseResult parse(OcrResult ocrResult) {
    final blocks = ocrResult.blocks;
    String? name;
    String? company;
    String? designation;
    final List<String> phones = [];
    final List<String> emails = [];
    String? website;
    String? address;
    String? linkedInUrl;
    String? twitterHandle;
    final Map<String, double> confidence = {};

    // --- Phase 1: Anchor detection (regex-based, high confidence) ---
    final phoneRegex = RegExp(
      r'(\+?\d{1,3}[\s\-]?)?'
      r'(\(?\d{2,4}\)?[\s\-]?)?'
      r'\d{3,4}[\s\-]?\d{3,5}',
    );
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}');
    final websiteRegex = RegExp(r'(https?://|www\.)[^\s]+', caseSensitive: false);
    final linkedInRegex = RegExp(r'linkedin\.com/in/[^\s]+', caseSensitive: false);
    final socialMediaRegex = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:linkedin\.com\/in\/|twitter\.com\/|facebook\.com\/|instagram\.com\/|x\.com\/)[A-Za-z0-9_\-\.]+',
      caseSensitive: false,
    );

    final List<OcrBlock> anchorBlocks = [];

    for (final block in blocks) {
      bool isAnchor = false;
      final text = block.text;

      final emailMatch = emailRegex.firstMatch(text);
      if (emailMatch != null) {
        final email = emailMatch.group(0)!;
        emails.add(email);
        // Signal-based: base 0.90, +0.03 for common TLD, +0.02 for name-like local part
        var emailConf = 0.90;
        final tld = email.split('.').last.toLowerCase();
        if (['com', 'org', 'net', 'io', 'co', 'in'].contains(tld)) emailConf += 0.03;
        final local = email.split('@').first;
        if (RegExp(r'^[a-z]+[\._]?[a-z]+$').hasMatch(local)) emailConf += 0.02;
        confidence['emails'] = emailConf.clamp(0.90, 0.95);
        isAnchor = true;
      }

      final phoneMatch = phoneRegex.firstMatch(text);
      if (phoneMatch != null) {
        final raw = phoneMatch.group(0)!;
        final normalized = _normalizeToE164(raw);
        phones.add(normalized);
        // Signal-based: base 0.85, +0.05 for explicit country code, +0.05 for proper length
        var phoneConf = 0.85;
        if (raw.startsWith('+')) phoneConf += 0.05;
        final digitCount = normalized.replaceAll(RegExp(r'[^0-9]'), '').length;
        if (digitCount >= 10 && digitCount <= 13) phoneConf += 0.05;
        confidence['phones'] = phoneConf.clamp(0.85, 0.95);
        isAnchor = true;
      }

      final linkedInMatch = linkedInRegex.firstMatch(text);
      if (linkedInMatch != null) {
        linkedInUrl = linkedInMatch.group(0)!;
        confidence['linkedInUrl'] = 0.92;
        isAnchor = true;
      }

      final socialMatch = socialMediaRegex.firstMatch(text);
      if (socialMatch != null) {
        twitterHandle = socialMatch.group(0)!;
        confidence['twitterHandle'] = 0.88;
        isAnchor = true;
      }

      final websiteMatch = websiteRegex.firstMatch(text);
      if (websiteMatch != null && linkedInMatch == null) {
        website = websiteMatch.group(0)!;
        // Signal-based: base 0.85, +0.05 for https, +0.03 for not a social site
        var webConf = 0.85;
        if (website.startsWith('https://')) webConf += 0.05;
        if (!socialMediaRegex.hasMatch(website)) webConf += 0.03;
        confidence['website'] = webConf.clamp(0.85, 0.93);
        isAnchor = true;
      }

      if (isAnchor) anchorBlocks.add(block);
    }

    final nonAnchorBlocks = blocks.where((b) => !anchorBlocks.contains(b)).toList();

    // --- Phase 2: Designation & Address (high confidence, narrow) ---
    final List<OcrBlock> designationBlocks = [];
    final List<OcrBlock> addressBlocks = [];

    OcrBlock? bestAddressBlock;
    double bestAddressScore = 0.0;

    for (final block in nonAnchorBlocks) {
      final textUpper = block.text.toUpperCase();

      if (designation == null) {
        for (final kw in designationKeywords) {
          final kwUpper = kw.toUpperCase();
          if (textUpper == kwUpper) {
            designation = block.text;
            // Exact match: highest confidence
            confidence['designation'] = 0.90;
            designationBlocks.add(block);
            break;
          } else if (textUpper.endsWith(' $kwUpper') || textUpper.startsWith('$kwUpper ')) {
            designation = block.text;
            // Prefix/suffix match: slightly lower
            confidence['designation'] = 0.80;
            designationBlocks.add(block);
            break;
          }
        }
      }

      // Address: structural signals only (postal code, street-type words, commas)
      // — no country/city/state gazetteer, so it is region-agnostic.
      final addrScore = _scoreAddress(block.text);
      if (addrScore > bestAddressScore) {
        bestAddressScore = addrScore;
        bestAddressBlock = block;
      }
    }

    if (bestAddressBlock != null && bestAddressScore >= 0.40) {
      address = bestAddressBlock.text;
      confidence['address'] = (0.45 + bestAddressScore * 0.45).clamp(0.45, 0.90);
      addressBlocks.add(bestAddressBlock);
    }

    // --- Phase 3: Name scoring (from remaining blocks) ---
    final usedBlocks = {...anchorBlocks, ...designationBlocks, ...addressBlocks};
    final availableBlocks = nonAnchorBlocks.where((b) => !usedBlocks.contains(b)).toList();

    final nameCandidates = availableBlocks.where((b) {
      final text = b.text.trim();
      for (final pattern in nonNamePatterns) {
        if (pattern.hasMatch(text)) return false;
      }
      if (text.length < 2) return false;
      final digitCount = RegExp(r'\d').allMatches(text).length;
      if (digitCount > text.length * 0.3) return false;
      return true;
    }).toList();

    // --- Pass 0: Identify company candidates (name-independent) ---
    final companyCandidates = _identifyCompanyCandidates(availableBlocks);

    if (nameCandidates.isNotEmpty) {
      final maxFont = nameCandidates.map((b) => b.fontSize).reduce(max);
      final maxY = nameCandidates.map((b) => b.rect.bottom).reduce(max);

      double bestScore = 0;
      OcrBlock? bestBlock;

      for (final block in nameCandidates) {
        final score = _computeNameScore(block, maxFont, maxY, companyCandidates);
        if (score > bestScore) {
          bestScore = score;
          bestBlock = block;
        }
      }

      if (bestBlock != null && bestScore >= 0.25) {
        name = bestBlock.text.trim();
        confidence['name'] = (0.50 + bestScore * 0.50).clamp(0.0, 1.0);
      }
    }

    // --- Pass 2: Final company selection (name-aware) ---
    final usedForCompany = {...anchorBlocks, ...designationBlocks, ...addressBlocks};
    if (name != null) {
      usedForCompany.addAll(availableBlocks.where((b) => b.text.trim() == name));
    }

    final companyPool = availableBlocks.where((b) => !usedForCompany.contains(b)).toList();
    if (companyPool.isNotEmpty && companyCandidates.isNotEmpty) {
      // Re-rank candidates with adjacency-to-name boost
      final nameBlock = nameCandidates.firstWhere(
        (b) => b.text.trim() == name,
        orElse: () => companyPool.first,
      );
      _rankCompanyCandidates(companyCandidates, companyPool, nameBlock);

      final best = companyCandidates.first;
      if (best.compositeScore <= 0) {
        // All candidates are too slogan-like — fall through to fallback
      } else {
        company = best.block.text;
        confidence['company'] = (0.55 + best.compositeScore * 0.35).clamp(0.60, 0.90);
      }
    }
    if (company == null && companyPool.isNotEmpty) {
      // Fallback: no candidates identified, pick most prominent non-slogan block
      companyPool.sort((a, b) {
        final aWords = a.text.split(RegExp(r'\s+')).length;
        final bWords = b.text.split(RegExp(r'\s+')).length;
        final aSlogan = _sloganPattern.hasMatch(a.text) ? 1 : 0;
        final bSlogan = _sloganPattern.hasMatch(b.text) ? 1 : 0;
        // Prefer: non-slogan first, then fewer words, then larger font
        if (aSlogan != bSlogan) return aSlogan - bSlogan;
        if (aWords != bWords) return aWords - bWords;
        return b.fontSize.compareTo(a.fontSize);
      });
      company = companyPool.first.text;
      confidence['company'] = 0.55;
    }

    // --- Phase 5: Flag low-confidence fields ---
    final List<String> flaggedFields = [];
    for (final field in [
      'name', 'company', 'designation', 'phones', 'emails',
      'website', 'address', 'linkedInUrl', 'twitterHandle',
    ]) {
      final score = confidence[field] ?? 0.0;
      if (score > 0 && score < ParserConfig.lowConfidence) {
        flaggedFields.add(field);
      }
    }

    return ParseResult(
      name: name,
      company: company,
      designation: designation,
      phones: phones,
      emails: emails,
      website: website,
      address: address,
      linkedInUrl: linkedInUrl,
      twitterHandle: twitterHandle,
      confidence: confidence,
      parseMode: 'local',
      flaggedFields: flaggedFields,
      ocrText: ocrResult.rawText,
    );
  }

  double _computeNameScore(
    OcrBlock block,
    double maxFont,
    double maxY,
    List<_CompanyCandidate> companyCandidates,
  ) {
    double score = 0.0;
    final text = block.text.trim();
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final wordCount = words.length;

    // Font size — any reasonable size gets credit
    if (maxFont > 0) {
      final ratio = block.fontSize / maxFont;
      if (ratio >= 0.5) {
        score += ParserConfig.nameWeightFontSize;
      } else {
        score += ParserConfig.nameWeightFontSize * ratio;
      }
    }

    // Title case OR consistent capitalization pattern (handles ALL CAPS names too)
    if (_looksLikeNameCase(text)) {
      score += ParserConfig.nameWeightTitleCase;
    }

    // Distance from top
    if (maxY > 0) {
      final normalizedY = 1.0 - (block.rect.top / maxY);
      score += normalizedY.clamp(0.0, 1.0) * ParserConfig.nameWeightTopDistance;
    }

    // No digits
    final hasDigits = RegExp(r'\d').hasMatch(text);
    if (!hasDigits) {
      score += ParserConfig.nameWeightNoDigits;
    }

    // No punctuation (ignoring initials like "C.")
    if (!_hasNonInitialPunctuation(text)) {
      score += ParserConfig.nameWeightNoPunctuation;
    }

    // Word count — 2-4 words is ideal for a name, 1 word is suspicious (likely company)
    if (wordCount >= 2 && wordCount <= 4) {
      score += ParserConfig.nameWeightWordCount;
    } else if (wordCount == 1) {
      score += ParserConfig.nameWeightWordCount * 0.2;
    } else if (wordCount == 5) {
      score += ParserConfig.nameWeightWordCount * 0.5;
    }

    // Proximity to company candidates — names cluster near their company on cards
    if (companyCandidates.isNotEmpty) {
      final minDist = companyCandidates
          .map((c) => _blockDistance(block, c.block))
          .reduce(min);
      final maxPossibleDist = 2000.0; // generous upper bound in pixels
      final proximity = (1.0 - (minDist / maxPossibleDist)).clamp(0.0, 1.0);
      score += proximity * ParserConfig.nameWeightProximityToCompany;
    }

    return score;
  }

  List<_CompanyCandidate> _identifyCompanyCandidates(List<OcrBlock> pool) {
    if (pool.isEmpty) return [];

    final maxFont = pool.map((b) => b.fontSize).reduce(max);
    final maxY = pool.map((b) => b.rect.bottom).reduce(max);
    final candidates = <_CompanyCandidate>[];

    for (final block in pool) {
      final text = block.text;
      final textLower = text.toLowerCase();
      final hasStrongSuffix = _strongCompanySuffixes.any(
        (s) => textLower.contains(s.toLowerCase()),
      );
      final hasWeakSuffix = !hasStrongSuffix && _weakCompanySuffixes.any(
        (s) => textLower.contains(s.toLowerCase()),
      );

      final fontSizeScore = maxFont > 0 ? (block.fontSize / maxFont).clamp(0.0, 1.0) : 0.5;
      final positionScore = maxY > 0 ? (1.0 - (block.rect.top / maxY)).clamp(0.0, 1.0) : 0.5;

      final wordCount = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      final hasSloganWords = _sloganPattern.hasMatch(text);

      // Word count penalty: 1-3 words ideal, 4+ words penalized (slogans are long)
      double wordCountPenalty = 0.0;
      if (wordCount >= 5) {
        wordCountPenalty = -0.25;
      } else if (wordCount >= 4) {
        wordCountPenalty = -0.15;
      }

      // Slogan pattern penalty
      final sloganPenalty = hasSloganWords ? -0.20 : 0.0;

      // Composite
      double composite;
      if (hasStrongSuffix) {
        composite = 0.50 + fontSizeScore * 0.3 + positionScore * 0.2;
      } else if (hasWeakSuffix) {
        composite = fontSizeScore * 0.6 + positionScore * 0.4 + 0.08;
      } else {
        composite = fontSizeScore * 0.6 + positionScore * 0.4;
      }
      composite = (composite + wordCountPenalty + sloganPenalty).clamp(0.0, 1.0);

      candidates.add(_CompanyCandidate(
        block: block,
        hasStrongSuffix: hasStrongSuffix,
        hasWeakSuffix: hasWeakSuffix,
        fontSizeScore: fontSizeScore,
        positionScore: positionScore,
        compositeScore: composite,
      ));
    }

    // Sort by composite score descending, keep top candidates
    candidates.sort((a, b) => b.compositeScore.compareTo(a.compositeScore));
    return candidates.take(5).toList();
  }

  void _rankCompanyCandidates(
    List<_CompanyCandidate> candidates,
    List<OcrBlock> companyPool,
    OcrBlock nameBlock,
  ) {
    if (candidates.isEmpty) return;

    final maxDist = 2000.0;
    for (final c in candidates) {
      if (!companyPool.contains(c.block)) {
        c.compositeScore = -1.0; // mark as invalid
        continue;
      }

      final dist = _blockDistance(c.block, nameBlock);
      final adjacency = (1.0 - (dist / maxDist)).clamp(0.0, 1.0);

      // Recompute with adjacency boost
      c.compositeScore = c.compositeScore * 0.80 + adjacency * 0.20;
    }

    candidates.sort((a, b) => b.compositeScore.compareTo(a.compositeScore));
  }

  double _blockDistance(OcrBlock a, OcrBlock b) {
    final acx = a.rect.left + a.rect.width / 2;
    final acy = a.rect.top + a.rect.height / 2;
    final bcx = b.rect.left + b.rect.width / 2;
    final bcy = b.rect.top + b.rect.height / 2;
    return sqrt((acx - bcx) * (acx - bcx) + (acy - bcy) * (acy - bcy));
  }

  bool _looksLikeNameCase(String text) {
    // Title Case: "John Smith" or "john smith" (all lowercase is fine too)
    if (text == _toTitleCase(text)) return true;
    // ALL CAPS: "VIVEK C. ZOPE" — valid for names
    if (text == text.toUpperCase() && text.length > 2) return true;
    // Mixed with initials: "Vivek C. Zope" or "VIVEK C. ZOPE"
    // Just check that every word starts with a capital or is an initial
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return false;
    final allStartUpper = words.every((w) {
      final first = w[0];
      return first == first.toUpperCase();
    });
    return allStartUpper && words.length >= 2;
  }

  bool _hasNonInitialPunctuation(String text) {
    // Check for punctuation that is NOT an initial (single letter + period)
    final cleaned = text.replaceAll(RegExp(r'\b[A-Za-z]\.'), '').trim();
    return cleaned.contains(RegExp(r'[^\w\s]'));
  }

  String _toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      // Preserve single-letter initials: "C." stays "C."
      if (word.length <= 2 && word.endsWith('.')) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Score a text block on how address-like it is, using structural signals that
  /// hold across countries: a postal-code shape, street-type/unit keywords, and
  /// comma-separated segments. Returns 0.0–1.0. No place-name lists.
  double _scoreAddress(String text) {
    if (text.trim().length < 6) return 0.0;
    final upper = text.toUpperCase();
    double score = 0.0;

    // Postal / ZIP code shape
    if (_postalCodePatterns.any((re) => re.hasMatch(text))) {
      score += 0.45;
    }

    // Street-type / unit keywords (whole-word match)
    var keywordHits = 0;
    for (final signal in addressSignals) {
      final s = signal.toUpperCase();
      final re = RegExp('(?<![A-Z])${RegExp.escape(s)}(?![A-Z])');
      if (re.hasMatch(upper)) {
        keywordHits++;
        if (keywordHits >= 2) break;
      }
    }
    score += (keywordHits * 0.30).clamp(0.0, 0.45);

    // Comma-separated segments (street, area, city, region ...)
    final commas = ','.allMatches(text).length;
    if (commas >= 2) {
      score += 0.25;
    } else if (commas == 1) {
      score += 0.10;
    }

    // A leading house/building number ("12 ...", "3/A ...") is a weak signal
    if (RegExp(r'^\s*\d{1,5}[/\-]?[A-Za-z]?\s+\S').hasMatch(text)) {
      score += 0.10;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Normalize a raw phone string toward E.164. If the number carries an explicit
  /// '+' country code it is kept as-is. Otherwise, when the device region is
  /// known, its calling code is prepended (dropping a national trunk '0'); when
  /// the region is unknown the number is left in national format rather than
  /// guessing a country.
  String _normalizeToE164(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return raw;

    if (digits.startsWith('+')) {
      return '+${digits.substring(1)}';
    }

    final hadTrunkZero = digits.startsWith('0');
    if (hadTrunkZero) digits = digits.substring(1);

    final code = _defaultCallingCode;
    if (code == null) {
      // Unknown region — don't fabricate a country code.
      return digits;
    }

    // Only expand when this looks like a bare national number. Longer strings
    // (or ones already beginning with the calling code) are assumed to carry a
    // country code that OCR dropped the '+' from.
    final looksNational = hadTrunkZero || digits.length <= 10;
    if (looksNational && !(digits.startsWith(code) && digits.length > 10)) {
      return '+$code$digits';
    }
    return '+$digits';
  }

  // FALLBACK: inline keyword lists used when asset loading fails or in tests
  static const List<String> _fallbackDesignations = [
    'CEO', 'CTO', 'CFO', 'COO', 'CMO', 'CIO', 'CISO', 'CRO', 'CSO',
    'Chief Executive Officer', 'Chief Technology Officer', 'Chief Financial Officer',
    'Chief Operating Officer', 'Chief Marketing Officer', 'Chief Information Officer',
    'VP', 'Vice President', 'SVP', 'EVP', 'AVP',
    'Director', 'Associate Director', 'Assistant Director', 'Executive Director',
    'Managing Director', 'Creative Director', 'Technical Director', 'Art Director',
    'Manager', 'Senior Manager', 'Associate Manager', 'Assistant Manager',
    'General Manager', 'Regional Manager', 'Area Manager', 'Branch Manager',
    'Project Manager', 'Program Manager', 'Product Manager', 'Portfolio Manager',
    'Operations Manager', 'Account Manager', 'Relationship Manager',
    'Lead', 'Team Lead', 'Tech Lead', 'Engineering Lead', 'Design Lead',
    'Growth Lead', 'Revenue Lead',
    'Senior', 'Junior', 'Staff', 'Principal', 'Distinguished', 'Fellow',
    'Engineer', 'Software Engineer', 'Senior Engineer', 'Staff Engineer',
    'Principal Engineer', 'Systems Engineer', 'Network Engineer',
    'DevOps Engineer', 'Site Reliability Engineer', 'QA Engineer',
    'Data Engineer', 'ML Engineer', 'AI Engineer', 'Cloud Engineer',
    'Security Engineer', 'Platform Engineer', 'Backend Engineer', 'Frontend Engineer',
    'Full Stack Developer', 'Mobile Developer', 'iOS Developer', 'Android Developer',
    'Developer', 'Programmer', 'Architect', 'Solution Architect',
    'Designer', 'UI Designer', 'UX Designer', 'UI/UX Designer', 'Product Designer',
    'Graphic Designer', 'Visual Designer', 'Interaction Designer', 'Brand Designer',
    'Motion Designer', 'Industrial Designer', 'Interior Designer',
    'Analyst', 'Data Analyst', 'Business Analyst', 'Financial Analyst',
    'Research Analyst', 'Security Analyst', 'Systems Analyst', 'Policy Analyst',
    'Data Scientist', 'Research Scientist', 'Machine Learning Scientist',
    'Sales Executive', 'Sales Manager', 'Sales Representative', 'Account Executive',
    'Account Director', 'Business Development', 'BD Manager', 'Partnership Manager',
    'Marketing Manager', 'Marketing Executive', 'Brand Manager', 'Growth Manager',
    'Content Strategist', 'SEO Specialist', 'SEM Specialist', 'Digital Marketing',
    'Social Media Manager', 'Public Relations', 'Communications Manager',
    'Accountant', 'Chartered Accountant', 'CA', 'Auditor', 'Controller',
    'Treasurer', 'Financial Advisor', 'Investment Banker',
    'Lawyer', 'Attorney', 'Legal Counsel', 'General Counsel', 'Paralegal',
    'Operations', 'Supply Chain', 'Logistics Manager', 'Procurement',
    'HR Manager', 'Human Resources', 'Talent Acquisition', 'Recruiter',
    'People Operations', 'Culture Manager',
    'Consultant', 'Senior Consultant', 'Principal Consultant', 'Management Consultant',
    'Strategy Consultant', 'Technology Consultant', 'Advisor', 'Senior Advisor',
    'Strategic Advisor', 'Business Advisor',
    'Founder', 'Co-Founder', 'Entrepreneur', 'Partner',
    'Managing Partner', 'General Partner',
    'Professor', 'Associate Professor', 'Assistant Professor', 'Lecturer',
    'Researcher', 'Postdoctoral Fellow', 'Department Head', 'Dean',
    'President', 'Chancellor', 'Provost', 'Vice Chancellor',
    'Doctor', 'Dr', 'Physician', 'Surgeon', 'Dentist', 'Pharmacist',
    'Nurse', 'Specialist', 'Resident', 'Medical Director',
    'Producer', 'Editor', 'Journalist', 'Reporter',
    'Photographer', 'Videographer', 'Content Creator',
    'Copywriter', 'Technical Writer', 'Author',
    'Civil Engineer', 'Mechanical Engineer', 'Electrical Engineer',
    'Chemical Engineer', 'Structural Engineer', 'Environmental Engineer',
    'Proprietor', 'Chairman', 'Chairperson', 'Secretary', 'Commissioner',
    'Superintendent', 'Coordinator', 'Supervisor', 'Administrator',
    'Associate', 'Executive', 'Officer', 'Representative',
    'Intern', 'Trainee', 'Apprentice', 'Scholar',
    'Head', 'Incharge', 'In-Charge',
  ];

  // FALLBACK: inline street-type / address-line keywords used when asset loading
  // fails or in tests. Structural words only — no city, state, or country names,
  // so address detection is not tied to any one region. A short set of
  // non-English street words is included since cards are often bilingual.
  static const List<String> _fallbackAddresses = [
    // English street / road types
    'Road', 'Rd', 'Street', 'St', 'Lane', 'Ln', 'Avenue', 'Ave',
    'Boulevard', 'Blvd', 'Drive', 'Dr', 'Court', 'Ct', 'Place', 'Pl',
    'Way', 'Circle', 'Cir', 'Terrace', 'Ter', 'Trail', 'Path', 'Row',
    'Square', 'Sq', 'Highway', 'Hwy', 'Parkway', 'Pkwy', 'Crescent', 'Close',
    // Unit / sub-address
    'Suite', 'Ste', 'Apt', 'Apartment', 'Unit', 'Room', 'Rm', 'Floor',
    'Flat', 'Building', 'Bldg', 'Tower', 'Block', 'Level', 'Wing',
    'PO Box', 'P.O. Box', 'Post Box', 'Mailbox',
    // Generic locality words (not proper names)
    'Sector', 'Phase', 'Plot', 'Industrial Area', 'Business Park',
    'Complex', 'Estate', 'Layout', 'Extension',
    // Postal-code labels
    'ZIP', 'PIN', 'Pincode', 'Postal Code', 'Post Code', 'Postcode',
    // Common non-English street words (bilingual cards)
    'Marg', 'Nagar', 'Jalan', 'Rue', 'Strasse', 'Straße', 'Via', 'Calle',
    'Avenida', 'Praça', 'Platz', 'Weg',
  ];
}
