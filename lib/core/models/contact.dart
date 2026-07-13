class Contact {
  final String id;
  final String name;
  final String? company;
  final String? designation;
  final List<String> phones;
  final List<String> emails;
  final String? website;
  final String? address;
  final String? imageFrontPath;
  final String? imageBackPath;
  final Map<String, double> confidence;
  final String parseMode;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastContactedAt;
  final bool isFavorite;
  final List<String> tags;
  final String? reminderNote;
  final DateTime? reminderDate;
  final bool reminderDone;
  final int scanCount;
  final String? linkedInUrl;
  final String? twitterHandle;
  // v3 metadata
  final String? aiModelUsed;
  final int? processingDurationMs;
  final int? ocrDurationMs;
  final int? parserDurationMs;
  final double? imageQualityScore;
  final String parserSource;
  final int parserVersion;

  Contact({
    required this.id,
    required this.name,
    this.company,
    this.designation,
    required this.phones,
    required this.emails,
    this.website,
    this.address,
    this.imageFrontPath,
    this.imageBackPath,
    required this.confidence,
    required this.parseMode,
    required this.createdAt,
    this.updatedAt,
    this.lastContactedAt,
    this.isFavorite = false,
    this.tags = const [],
    this.reminderNote,
    this.reminderDate,
    this.reminderDone = false,
    this.scanCount = 1,
    this.linkedInUrl,
    this.twitterHandle,
    this.aiModelUsed,
    this.processingDurationMs,
    this.ocrDurationMs,
    this.parserDurationMs,
    this.imageQualityScore,
    this.parserSource = 'local',
    this.parserVersion = 1,
  });

  Contact copyWith({
    String? name,
    String? company,
    String? designation,
    List<String>? phones,
    List<String>? emails,
    String? website,
    String? address,
    String? imageFrontPath,
    String? imageBackPath,
    Map<String, double>? confidence,
    String? parseMode,
    DateTime? updatedAt,
    DateTime? lastContactedAt,
    bool? isFavorite,
    List<String>? tags,
    String? reminderNote,
    DateTime? reminderDate,
    bool? reminderDone,
    int? scanCount,
    String? linkedInUrl,
    String? twitterHandle,
    String? aiModelUsed,
    int? processingDurationMs,
    int? ocrDurationMs,
    int? parserDurationMs,
    double? imageQualityScore,
    String? parserSource,
    int? parserVersion,
  }) {
    return Contact(
      id: id,
      name: name ?? this.name,
      company: company ?? this.company,
      designation: designation ?? this.designation,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
      website: website ?? this.website,
      address: address ?? this.address,
      imageFrontPath: imageFrontPath ?? this.imageFrontPath,
      imageBackPath: imageBackPath ?? this.imageBackPath,
      confidence: confidence ?? this.confidence,
      parseMode: parseMode ?? this.parseMode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      reminderNote: reminderNote ?? this.reminderNote,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderDone: reminderDone ?? this.reminderDone,
      scanCount: scanCount ?? this.scanCount,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      twitterHandle: twitterHandle ?? this.twitterHandle,
      aiModelUsed: aiModelUsed ?? this.aiModelUsed,
      processingDurationMs: processingDurationMs ?? this.processingDurationMs,
      ocrDurationMs: ocrDurationMs ?? this.ocrDurationMs,
      parserDurationMs: parserDurationMs ?? this.parserDurationMs,
      imageQualityScore: imageQualityScore ?? this.imageQualityScore,
      parserSource: parserSource ?? this.parserSource,
      parserVersion: parserVersion ?? this.parserVersion,
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      company: json['company'],
      designation: json['designation'],
      phones: List<String>.from(json['phones'] ?? []),
      emails: List<String>.from(json['emails'] ?? []),
      website: json['website'],
      address: json['address'],
      imageFrontPath: json['imageFrontPath'],
      imageBackPath: json['imageBackPath'],
      confidence: Map<String, double>.from(json['confidence'] ?? {}),
      parseMode: json['parseMode'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastContactedAt: json['lastContactedAt'] != null ? DateTime.parse(json['lastContactedAt']) : null,
      isFavorite: json['isFavorite'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      reminderNote: json['reminderNote'],
      reminderDate: json['reminderDate'] != null ? DateTime.parse(json['reminderDate']) : null,
      reminderDone: json['reminderDone'] ?? false,
      scanCount: json['scanCount'] ?? 1,
      linkedInUrl: json['linkedInUrl'],
      twitterHandle: json['twitterHandle'],
      aiModelUsed: json['aiModelUsed'],
      processingDurationMs: json['processingDurationMs'],
      ocrDurationMs: json['ocrDurationMs'],
      parserDurationMs: json['parserDurationMs'],
      imageQualityScore: json['imageQualityScore']?.toDouble(),
      parserSource: json['parserSource'] ?? 'local',
      parserVersion: json['parserVersion'] ?? 1,
    );
  }
}
