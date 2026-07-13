import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../scan/image_processor.dart';
import '../scan/ocr_service.dart';
import 'local_parser.dart';
import 'confidence_engine.dart';
import 'ai_parser.dart';
import 'merge_engine.dart';
import '../../core/models/parse_result.dart';
import '../../core/models/scan_metadata.dart';
import '../../core/config/parser_config.dart';

class PipelineResult {
  final ParseResult parseResult;
  final OcrResult ocrResult;

  const PipelineResult({required this.parseResult, required this.ocrResult});
}

class ParsePipeline {
  final ImageProcessor _imageProcessor = ImageProcessor();
  final OcrService _ocrService = OcrService.instance;
  LocalParser _localParser = LocalParser();
  final ConfidenceEngine _confidenceEngine = ConfidenceEngine();
  final AiParser _aiParser = AiParser();

  ParsePipeline();

  static Future<ParsePipeline> create() async {
    final pipeline = ParsePipeline();
    await pipeline._init();
    return pipeline;
  }

  Future<void> _init() async {
    List<String>? designations;
    List<String>? addresses;
    try {
      final dJson = await rootBundle.loadString('assets/designations.json');
      designations = List<String>.from(jsonDecode(dJson));
    } catch (_) {
      // FALLBACK: use inline defaults in LocalParser
    }
    try {
      final aJson = await rootBundle.loadString('assets/addresses.json');
      addresses = List<String>.from(jsonDecode(aJson));
    } catch (_) {
      // FALLBACK: use inline defaults in LocalParser
    }
    _localParser = LocalParser(
      designations: designations,
      addresses: addresses,
    );
  }

  Future<PipelineResult> process(String imagePath, {String? imagePathBack, bool alreadyCorrected = false}) async {
    final totalStopwatch = Stopwatch()..start();

    // Step 1: Preprocess image
    final processedPath = await _imageProcessor.processImage(imagePath, alreadyCorrected: alreadyCorrected);
    final imageQuality = await _imageProcessor.computeQualityScore(processedPath);

    // Step 2: OCR
    final ocrStopwatch = Stopwatch()..start();
    final ocrResult = await _ocrService.recognizeText(processedPath);
    ocrStopwatch.stop();

    // Step 3: Local parsing
    final parserStopwatch = Stopwatch()..start();
    var localResult = _localParser.parse(ocrResult);
    parserStopwatch.stop();

    localResult = localResult.copyWith(
      imageFrontPath: imagePath,
      imageBackPath: imagePathBack,
      imageQualityScore: imageQuality,
    );

    // Step 4: Confidence evaluation → decide AI escalation
    final shouldUseAi = _confidenceEngine.shouldTriggerAi(localResult, ocrResult);

    // Step 5: AI escalation (only if needed and enabled)
    ParseResult? aiResult;
    String? aiModel;
    if (shouldUseAi) {
      final avgConf = _confidenceEngine.averageConfidence(localResult);
      aiResult = await _aiParser.parse(ocrResult, processedPath, avgConf);
      if (aiResult != null) {
        aiModel = 'gpt-4o';
      }
    }

    // Step 6: Merge (field-level)
    final mergedResult = MergeEngine.merge(localResult, aiResult);

    totalStopwatch.stop();

    // Build metadata
    final metadata = ScanMetadata(
      parserVersion: ParserConfig.parserVersion,
      ocrVersion: ParserConfig.ocrVersion,
      preprocessingVersion: ParserConfig.preprocessingVersion,
      aiModelUsed: aiModel,
      processingDurationMs: totalStopwatch.elapsedMilliseconds,
      ocrDurationMs: ocrStopwatch.elapsedMilliseconds,
      parserDurationMs: parserStopwatch.elapsedMilliseconds,
      imageQualityScore: imageQuality,
      parserSource: aiModel ?? 'local',
    );

    return PipelineResult(
      parseResult: mergedResult.copyWith(metadata: metadata),
      ocrResult: ocrResult,
    );
  }
}
