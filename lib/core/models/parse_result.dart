import 'scan_metadata.dart';

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
  final String? ocrText;
  final String? notes;
  final double? imageQualityScore;
  final ScanMetadata? metadata;

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
    this.ocrText,
    this.notes,
    this.imageQualityScore,
    this.metadata,
  });

  ParseResult copyWith({
    String? name,
    String? company,
    String? designation,
    List<String>? phones,
    List<String>? emails,
    String? website,
    String? address,
    String? linkedInUrl,
    String? twitterHandle,
    Map<String, double>? confidence,
    String? parseMode,
    List<String>? flaggedFields,
    String? imageFrontPath,
    String? imageBackPath,
    String? ocrText,
    String? notes,
    double? imageQualityScore,
    ScanMetadata? metadata,
  }) {
    return ParseResult(
      name: name ?? this.name,
      company: company ?? this.company,
      designation: designation ?? this.designation,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
      website: website ?? this.website,
      address: address ?? this.address,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      twitterHandle: twitterHandle ?? this.twitterHandle,
      confidence: confidence ?? this.confidence,
      parseMode: parseMode ?? this.parseMode,
      flaggedFields: flaggedFields ?? this.flaggedFields,
      imageFrontPath: imageFrontPath ?? this.imageFrontPath,
      imageBackPath: imageBackPath ?? this.imageBackPath,
      ocrText: ocrText ?? this.ocrText,
      notes: notes ?? this.notes,
      imageQualityScore: imageQualityScore ?? this.imageQualityScore,
      metadata: metadata ?? this.metadata,
    );
  }

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
      flaggedFields: mergedConf.entries.where((e) => e.value < 0.65 && e.value > 0).map((e) => e.key).toList(),
      imageFrontPath: other.imageFrontPath ?? imageFrontPath,
      imageBackPath: other.imageBackPath ?? imageBackPath,
      ocrText: other.ocrText ?? ocrText,
      notes: other.notes ?? notes,
      imageQualityScore: other.imageQualityScore ?? imageQualityScore,
      metadata: other.metadata ?? metadata,
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
    'ocrText': ocrText,
    'notes': notes,
    'imageQualityScore': imageQualityScore,
    'metadata': metadata?.toJson(),
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
    ocrText: json['ocrText'],
    notes: json['notes'],
    imageQualityScore: json['imageQualityScore']?.toDouble(),
    metadata: json['metadata'] != null ? ScanMetadata.fromJson(json['metadata']) : null,
  );
}
