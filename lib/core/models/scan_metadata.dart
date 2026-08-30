class ScanMetadata {
  final int parserVersion;
  final int ocrVersion;
  final int preprocessingVersion;
  final String? aiModelUsed;
  final String? aiProviderUsed;
  final int processingDurationMs;
  final int ocrDurationMs;
  final int parserDurationMs;
  final double? imageQualityScore;
  final String parserSource;

  /// Set when AI parsing was enabled but its result was dropped (bad key,
  /// unknown model, network, unparseable response). Surfaced on the review
  /// screen so "Local" isn't a silent mystery.
  final String? aiError;

  const ScanMetadata({
    required this.parserVersion,
    required this.ocrVersion,
    required this.preprocessingVersion,
    this.aiModelUsed,
    this.aiProviderUsed,
    required this.processingDurationMs,
    required this.ocrDurationMs,
    required this.parserDurationMs,
    this.imageQualityScore,
    required this.parserSource,
    this.aiError,
  });

  Map<String, dynamic> toJson() => {
    'parserVersion': parserVersion,
    'ocrVersion': ocrVersion,
    'preprocessingVersion': preprocessingVersion,
    'aiModelUsed': aiModelUsed,
    'aiProviderUsed': aiProviderUsed,
    'processingDurationMs': processingDurationMs,
    'ocrDurationMs': ocrDurationMs,
    'parserDurationMs': parserDurationMs,
    'imageQualityScore': imageQualityScore,
    'parserSource': parserSource,
    'aiError': aiError,
  };

  factory ScanMetadata.fromJson(Map<String, dynamic> json) => ScanMetadata(
    parserVersion: json['parserVersion'] ?? 1,
    ocrVersion: json['ocrVersion'] ?? 1,
    preprocessingVersion: json['preprocessingVersion'] ?? 1,
    aiModelUsed: json['aiModelUsed'],
    aiProviderUsed: json['aiProviderUsed'],
    processingDurationMs: json['processingDurationMs'] ?? 0,
    ocrDurationMs: json['ocrDurationMs'] ?? 0,
    parserDurationMs: json['parserDurationMs'] ?? 0,
    imageQualityScore: json['imageQualityScore']?.toDouble(),
    parserSource: json['parserSource'] ?? 'local',
    aiError: json['aiError'],
  );
}
