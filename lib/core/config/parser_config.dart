class ParserConfig {
  ParserConfig._();

  // Version identifiers (bump when parsing logic changes)
  static const int parserVersion = 2;
  static const int ocrVersion = 1;
  static const int preprocessingVersion = 2;

  // Confidence thresholds
  static const double aiTriggerAvgThreshold = 0.72;
  static const int aiTriggerMinHighConfFields = 3;
  static const double highConfidence = 0.80;
  static const double mediumConfidence = 0.65;
  static const double lowConfidence = 0.65;

  // Name scoring weights (must sum to 1.0)
  static const double nameWeightFontSize = 0.25;
  static const double nameWeightTitleCase = 0.20;
  static const double nameWeightTopDistance = 0.15;
  static const double nameWeightNoDigits = 0.15;
  static const double nameWeightNoPunctuation = 0.10;
  static const double nameWeightWordCount = 0.10;
  static const double nameWeightProximityToCompany = 0.05;

  // Duplicate detection
  static const int levenshteinThreshold = 2;

  // Image processing
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;
  static const double deskewAngleLimit = 15.0;
}
