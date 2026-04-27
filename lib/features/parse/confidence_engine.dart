import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/parse_result.dart';
import '../../core/database/database.dart';

class ConfidenceEngine {
  bool shouldTriggerAi(ParseResult localResult) {
    if (localResult.confidence.isEmpty) return true;

    final values = localResult.confidence.values.toList();
    final average = values.reduce((a, b) => a + b) / values.length;

    if (average < 0.72) return true;

    final highConfidenceCount = values.where((v) => v > 0.8).length;
    if (highConfidenceCount < 3) return true;

    return false;
  }

  Future<void> saveDraftAndNavigate(BuildContext context, ParseResult parseResult, String? imageFrontPath, String? imageBackPath) async {
    final db = context.read<AppDatabase>();
    final draftId = const Uuid().v4();
    await db.contactsDao.saveDraft(draftId, parseResult, imageFrontPath, imageBackPath);
    if (context.mounted) {
      context.go('/review/$draftId');
    }
  }
}
