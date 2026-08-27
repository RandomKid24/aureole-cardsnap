import 'dart:io';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrBlock {
  final String text;
  final Rect rect;
  final double fontSize;
  final double confidence;
  final int blockIndex;
  final double rotation;

  OcrBlock({
    required this.text,
    required this.rect,
    required this.fontSize,
    this.confidence = 1.0,
    this.blockIndex = 0,
    this.rotation = 0.0,
  });
}

class OcrResult {
  final List<OcrBlock> blocks;
  final int imageWidth;
  final int imageHeight;
  final String rawText;

  OcrResult({
    required this.blocks,
    required this.imageWidth,
    required this.imageHeight,
    required this.rawText,
  });
}

class OcrService {
  OcrService._();
  static final OcrService instance = OcrService._();

  final Map<TextRecognitionScript, TextRecognizer> _recognizers = {};

  TextRecognizer _getRecognizer({TextRecognitionScript script = TextRecognitionScript.latin}) {
    return _recognizers.putIfAbsent(script, () => TextRecognizer(script: script));
  }

  Future<OcrResult> recognizeText(
    String imagePath, {
    TextRecognitionScript script = TextRecognitionScript.latin,
    bool retried = false,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    // Get image dimensions for metadata
    final file = File(imagePath);
    int imageWidth = 0;
    int imageHeight = 0;
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      imageWidth = frame.image.width;
      imageHeight = frame.image.height;
      frame.image.dispose();
      codec.dispose();
    }

    try {
      final rec = _getRecognizer(script: script);
      final RecognizedText recognizedText = await rec.processImage(inputImage);
      final List<OcrBlock> blocks = [];
      final buffer = StringBuffer();

      int blockIdx = 0;
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text;
          blocks.add(OcrBlock(
            text: text,
            rect: line.boundingBox,
            fontSize: line.boundingBox.height,
            blockIndex: blockIdx,
            rotation: 0.0,
          ));
          buffer.write(text);
          buffer.write(' ');
        }
        blockIdx++;
      }

      blocks.sort((a, b) => a.rect.top.compareTo(b.rect.top));

      return OcrResult(
        blocks: blocks,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        rawText: buffer.toString().trim(),
      );
    } on Exception {
      await close();
      if (retried) rethrow;
      return recognizeText(imagePath, script: script, retried: true);
    }
  }

  Future<void> close() async {
    for (final r in _recognizers.values) {
      await r.close();
    }
    _recognizers.clear();
  }

  void dispose() {
    close();
  }
}
