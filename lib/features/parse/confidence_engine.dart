import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/parse_result.dart';

import '../../core/database/database.dart';
import '../../core/config/parser_config.dart';
import '../scan/ocr_service.dart';

class ConfidenceEngine {
  bool shouldTriggerAi(ParseResult localResult, OcrResult ocrResult) {
    // 1. No confidence data → trigger
    if (localResult.confidence.isEmpty) return true;

    final values = localResult.confidence.values.toList();

    // 2. Average confidence below threshold → trigger
    final average = values.reduce((a, b) => a + b) / values.length;
    if (average < ParserConfig.aiTriggerAvgThreshold) return true;

    // 3. Fewer than N high-confidence fields → trigger
    final highCount = values.where((v) => v > ParserConfig.highConfidence).length;
    if (highCount < ParserConfig.aiTriggerMinHighConfFields) return true;

    // 4. Required fields missing (name or company) → trigger
    if (localResult.name == null || localResult.name!.isEmpty) return true;
    if (localResult.company == null || localResult.company!.isEmpty) return true;

    // 5. OCR extracted very little useful text → trigger
    if (ocrResult.rawText.trim().length < 20) return true;

    // 6. Image quality is poor → trigger
    if (localResult.imageQualityScore != null && localResult.imageQualityScore! < 0.3) return true;

    return false;
  }

  double averageConfidence(ParseResult result) {
    if (result.confidence.isEmpty) return 0.0;
    final values = result.confidence.values.toList();
    return values.reduce((a, b) => a + b) / values.length;
  }

  Future<void> saveDraftAndNavigate(
    BuildContext context,
    ParseResult parseResult,
    String? imageFrontPath,
    String? imageBackPath,
  ) async {
    final db = context.read<AppDatabase>();
    final draftId = const Uuid().v4();
    await db.contactsDao.saveDraft(draftId, parseResult, imageFrontPath, imageBackPath);
    if (context.mounted) {
      context.go('/review/$draftId');
    }
  }
}
