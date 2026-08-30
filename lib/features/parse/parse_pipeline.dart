import 'dart:async';
import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/services.dart';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../scan/image_processor.dart';
import '../scan/ocr_service.dart';
import 'local_parser.dart';
import 'confidence_engine.dart';
import 'ai_parser.dart';
import 'merge_engine.dart';
import 'corrections_store.dart';
import '../../core/database/database.dart';
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

  /// {parsedValue -> userCorrectedValue} learned from past review edits,
  /// keyed by field ('name', 'company', 'designation').
  Map<String, Map<String, String>> _corrections = const {};

  /// OCR script model, chosen from the device language. The non-Latin models
  /// also recognise Latin text, so a Hindi/Marathi locale still reads English.
  TextRecognitionScript _script = TextRecognitionScript.latin;

  static const _devanagariLangs = {'hi', 'mr', 'ne', 'sa', 'kok', 'mai', 'bho', 'doi'};

  ParsePipeline();

  static Future<ParsePipeline> create({AppDatabase? db}) async {
    final pipeline = ParsePipeline();
    await pipeline._init(db);
    return pipeline;
  }

  Future<void> _init(AppDatabase? db) async {
    if (db != null) {
      try {
        final store = CorrectionsStore(db);
        _corrections = {
          'company': await store.getCorrectionMap('company'),
          'name': await store.getCorrectionMap('name'),
          'designation': await store.getCorrectionMap('designation'),
        };
      } catch (_) {
        _corrections = const {};
      }
    }

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
    // Device region (ISO country) — used only to expand bare national phone
    // numbers. Never assume a country when the locale doesn't provide one.
    final locale = PlatformDispatcher.instance.locale;
    final region = locale.countryCode;
    if (_devanagariLangs.contains(locale.languageCode)) {
      _script = TextRecognitionScript.devanagiri;
    }

    _localParser = LocalParser(
      designations: designations,
      addresses: addresses,
      region: region,
    );
  }

  Future<PipelineResult> process(String imagePath, {String? imagePathBack, bool alreadyCorrected = false}) async {
    final totalStopwatch = Stopwatch()..start();

    // Step 1: Preprocess image
    final processedPath = await _imageProcessor.processImage(imagePath, alreadyCorrected: alreadyCorrected);
    final imageQuality = await _imageProcessor.computeQualityScore(processedPath);

    // Step 2: OCR (front, plus back when a second image was captured)
    final ocrStopwatch = Stopwatch()..start();
    var ocrResult = await _ocrService.recognizeText(processedPath, script: _script);
    OcrResult? backOcr;
    if (imagePathBack != null) {
      try {
        final processedBack = await _imageProcessor.processImage(imagePathBack, alreadyCorrected: alreadyCorrected);
        backOcr = await _ocrService.recognizeText(processedBack, script: _script);
      } catch (_) {
        backOcr = null;
      }
    }
    ocrStopwatch.stop();

    // Step 3: Local parsing (front, then merge anything the back adds)
    final parserStopwatch = Stopwatch()..start();
    var localResult = _localParser.parse(ocrResult);
    if (backOcr != null && backOcr.blocks.isNotEmpty) {
      final backResult = _localParser.parse(backOcr);
      final combinedText = '${ocrResult.rawText}\n${backOcr.rawText}'.trim();
      localResult = MergeEngine.merge(localResult, backResult).copyWith(ocrText: combinedText);
      ocrResult = OcrResult(
        blocks: [...ocrResult.blocks, ...backOcr.blocks],
        imageWidth: ocrResult.imageWidth,
        imageHeight: ocrResult.imageHeight,
        rawText: combinedText,
      );
    }
    parserStopwatch.stop();

    localResult = localResult.copyWith(
      imageFrontPath: imagePath,
      imageBackPath: imagePathBack,
      imageQualityScore: imageQuality,
    );

    // Step 4/5: AI parse. If the user has AI enabled, always run it (they turned
    // it on to get better results — a confidently-wrong local parse shouldn't
    // suppress it). Otherwise fall back to the confidence-based trigger.
    final aiEnabled = await _aiParser.isUsable();
    final shouldUseAi = aiEnabled ||
        _confidenceEngine.shouldTriggerAi(localResult, ocrResult);

    ParseResult? aiResult;
    String? aiModel;
    String? aiProvider;
    String? aiError;
    if (shouldUseAi && ocrResult.rawText.trim().length >= 12) {
      final avgConf = _confidenceEngine.averageConfidence(localResult);
      aiResult = await _aiParser.parse(ocrResult, processedPath, avgConf);
      final config = _aiParser.lastConfig;
      if (aiResult != null) {
        aiModel = config?.effectiveModel;
        aiProvider = config?.displayName;
      } else if (aiEnabled) {
        aiError = _aiParser.lastError;
      }
    }

    // Step 6: Merge (field-level), then apply learned corrections
    final mergedResult = _applyCorrections(MergeEngine.merge(localResult, aiResult));

    totalStopwatch.stop();

    // Build metadata
    final metadata = ScanMetadata(
      parserVersion: ParserConfig.parserVersion,
      ocrVersion: ParserConfig.ocrVersion,
      preprocessingVersion: ParserConfig.preprocessingVersion,
      aiModelUsed: aiModel,
      aiProviderUsed: aiProvider,
      processingDurationMs: totalStopwatch.elapsedMilliseconds,
      ocrDurationMs: ocrStopwatch.elapsedMilliseconds,
      parserDurationMs: parserStopwatch.elapsedMilliseconds,
      imageQualityScore: imageQuality,
      parserSource: aiModel ?? 'local',
      aiError: aiError,
    );

    return PipelineResult(
      parseResult: mergedResult.copyWith(metadata: metadata),
      ocrResult: ocrResult,
    );
  }

  /// If the user has previously corrected the same parsed value for a field,
  /// apply that correction and mark the field high-confidence.
  ParseResult _applyCorrections(ParseResult r) {
    if (_corrections.isEmpty) return r;

    String? fix(String field, String? value) {
      if (value == null || value.isEmpty) return value;
      return _corrections[field]?[value] ?? value;
    }

    final newName = fix('name', r.name);
    final newCompany = fix('company', r.company);
    final newDesignation = fix('designation', r.designation);

    final conf = Map<String, double>.from(r.confidence);
    if (newName != r.name) conf['name'] = 0.95;
    if (newCompany != r.company) conf['company'] = 0.95;
    if (newDesignation != r.designation) conf['designation'] = 0.95;

    return r.copyWith(
      name: newName,
      company: newCompany,
      designation: newDesignation,
      confidence: conf,
    );
  }
}
