import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrBlock {
  final String text;
  final Rect rect;
  final double fontSize;
  final double confidence;

  OcrBlock({
    required this.text,
    required this.rect,
    required this.fontSize,
    this.confidence = 1.0,
  });
}

class OcrService {
  OcrService._();
  static final OcrService instance = OcrService._();

  TextRecognizer? _recognizer;

  TextRecognizer get _rec {
    _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _recognizer!;
  }

  Future<List<OcrBlock>> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    
    try {
      final RecognizedText recognizedText = await _rec.processImage(inputImage);
      final List<OcrBlock> blocks = [];

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          blocks.add(OcrBlock(
            text: line.text,
            rect: line.boundingBox,
            fontSize: line.boundingBox.height,
          ));
        }
      }

      blocks.sort((a, b) => a.rect.top.compareTo(b.rect.top));
      return blocks;
    } on Exception {
      // Stale native object — reset and retry once
      await close();
      return recognizeText(imagePath);
    }
  }

  Future<void> close() async {
    await _recognizer?.close();
    _recognizer = null;
  }

  void dispose() {
    close();
  }
}
