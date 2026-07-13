import '../../core/models/parse_result.dart';
import '../../core/config/parser_config.dart';

class MergeEngine {
  MergeEngine._();

  /// Merge local and AI parse results at field level.
  /// For each field, use whichever source has higher confidence.
  /// Never replace the entire result — only upgrade individual fields.
  static ParseResult merge(ParseResult local, ParseResult? ai) {
    if (ai == null) return local;

    final mergedConfidence = Map<String, double>.from(local.confidence);

    String? pickBest(String? localVal, double localConf, String? aiVal, double aiConf, String field) {
      if (aiVal != null && aiVal.isNotEmpty && aiConf > localConf) {
        mergedConfidence[field] = aiConf;
        return aiVal;
      }
      return localVal;
    }

    List<String> pickBestList(List<String> localList, double localConf, List<String> aiList, double aiConf, String field) {
      if (aiList.isNotEmpty && aiConf > localConf) {
        mergedConfidence[field] = aiConf;
        return aiList;
      }
      return localList;
    }

    final merged = ParseResult(
      name: pickBest(
        local.name, local.confidence['name'] ?? 0,
        ai.name, ai.confidence['name'] ?? 0,
        'name',
      ),
      company: pickBest(
        local.company, local.confidence['company'] ?? 0,
        ai.company, ai.confidence['company'] ?? 0,
        'company',
      ),
      designation: pickBest(
        local.designation, local.confidence['designation'] ?? 0,
        ai.designation, ai.confidence['designation'] ?? 0,
        'designation',
      ),
      phones: pickBestList(
        local.phones, local.confidence['phones'] ?? 0,
        ai.phones, ai.confidence['phones'] ?? 0,
        'phones',
      ),
      emails: pickBestList(
        local.emails, local.confidence['emails'] ?? 0,
        ai.emails, ai.confidence['emails'] ?? 0,
        'emails',
      ),
      website: pickBest(
        local.website, local.confidence['website'] ?? 0,
        ai.website, ai.confidence['website'] ?? 0,
        'website',
      ),
      address: pickBest(
        local.address, local.confidence['address'] ?? 0,
        ai.address, ai.confidence['address'] ?? 0,
        'address',
      ),
      linkedInUrl: pickBest(
        local.linkedInUrl, local.confidence['linkedInUrl'] ?? 0,
        ai.linkedInUrl, ai.confidence['linkedInUrl'] ?? 0,
        'linkedInUrl',
      ),
      twitterHandle: pickBest(
        local.twitterHandle, local.confidence['twitterHandle'] ?? 0,
        ai.twitterHandle, ai.confidence['twitterHandle'] ?? 0,
        'twitterHandle',
      ),
      confidence: mergedConfidence,
      parseMode: ai.parseMode,
      ocrText: local.ocrText,
      imageQualityScore: local.imageQualityScore,
      metadata: local.metadata,
      imageFrontPath: local.imageFrontPath,
      imageBackPath: local.imageBackPath,
    );

    // Recompute flagged fields
    final flagged = <String>[];
    for (final entry in mergedConfidence.entries) {
      if (entry.value > 0 && entry.value < ParserConfig.lowConfidence) {
        flagged.add(entry.key);
      }
    }

    return merged.copyWith(flaggedFields: flagged);
  }
}
