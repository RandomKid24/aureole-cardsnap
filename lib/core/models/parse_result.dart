class ParseResult {
  final String? name;
  final String? company;
  final String? designation;
  final List<String> phones;
  final List<String> emails;
  final String? website;
  final String? address;
  final String? linkedInUrl;
  final String? twitterHandle;
  final Map<String, double> confidence;
  final String parseMode;
  final List<String> flaggedFields;
  final String? imageFrontPath;
  final String? imageBackPath;

  ParseResult({
    this.name,
    this.company,
    this.designation,
    this.phones = const [],
    this.emails = const [],
    this.website,
    this.address,
    this.linkedInUrl,
    this.twitterHandle,
    required this.confidence,
    required this.parseMode,
    this.flaggedFields = const [],
    this.imageFrontPath,
    this.imageBackPath,
  });

  ParseResult mergeWith(ParseResult other) {
    final mergedConf = Map<String, double>.from(confidence);
    other.confidence.forEach((k, v) {
      if (!mergedConf.containsKey(k) || v > mergedConf[k]!) mergedConf[k] = v;
    });

    return ParseResult(
      name: (other.confidence['name'] ?? 0) > (confidence['name'] ?? 0) ? other.name : name,
      company: (other.confidence['company'] ?? 0) > (confidence['company'] ?? 0) ? other.company : company,
      designation: (other.confidence['designation'] ?? 0) > (confidence['designation'] ?? 0) ? other.designation : designation,
      phones: other.phones.isNotEmpty ? other.phones : phones,
      emails: other.emails.isNotEmpty ? other.emails : emails,
      website: (other.confidence['website'] ?? 0) > (confidence['website'] ?? 0) ? other.website : website,
      address: (other.confidence['address'] ?? 0) > (confidence['address'] ?? 0) ? other.address : address,
      linkedInUrl: other.linkedInUrl ?? linkedInUrl,
      twitterHandle: other.twitterHandle ?? twitterHandle,
      confidence: mergedConf,
      parseMode: other.parseMode == 'ai' ? 'ai' : parseMode,
      flaggedFields: mergedConf.entries.where((e) => e.value < 0.65).map((e) => e.key).toList(),
      imageFrontPath: other.imageFrontPath ?? imageFrontPath,
      imageBackPath: other.imageBackPath ?? imageBackPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'company': company,
    'designation': designation,
    'phones': phones,
    'emails': emails,
    'website': website,
    'address': address,
    'linkedInUrl': linkedInUrl,
    'twitterHandle': twitterHandle,
    'confidence': confidence,
    'parseMode': parseMode,
    'flaggedFields': flaggedFields,
    'imageFrontPath': imageFrontPath,
    'imageBackPath': imageBackPath,
  };

  factory ParseResult.fromJson(Map<String, dynamic> json) => ParseResult(
    name: json['name'],
    company: json['company'],
    designation: json['designation'],
    phones: List<String>.from(json['phones'] ?? []),
    emails: List<String>.from(json['emails'] ?? []),
    website: json['website'],
    address: json['address'],
    linkedInUrl: json['linkedInUrl'],
    twitterHandle: json['twitterHandle'],
    confidence: Map<String, double>.from(json['confidence'] ?? {}),
    parseMode: json['parseMode'] ?? 'local',
    flaggedFields: List<String>.from(json['flaggedFields'] ?? []),
    imageFrontPath: json['imageFrontPath'],
    imageBackPath: json['imageBackPath'],
  );
}
