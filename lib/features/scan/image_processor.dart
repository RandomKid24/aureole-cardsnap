import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class ImageProcessor {
  Future<String> processImage(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    
    final processedBytes = await compute(_processAndEncodeImage, bytes);

    // Save to temp initially for processing
    final tempDir = await getTemporaryDirectory();
    final processedPath = path.join(tempDir.path, 'temp_processed_${DateTime.now().millisecondsSinceEpoch}.png');
    
    await File(processedPath).writeAsBytes(processedBytes);
    return processedPath;
  }

  static Uint8List _processAndEncodeImage(Uint8List bytes) {
    img.Image? image = img.decodeImage(bytes);

    if (image == null) throw Exception("Could not decode image");

    image = img.grayscale(image);

    // Compute mean pixel luminance (0–255)
    final pixels = image.getBytes(order: img.ChannelOrder.rgb);
    final mean = pixels.fold<int>(0, (s, b) => s + b) / pixels.length;

    // Dark cards need less contrast boost to avoid crushing blacks;
    // light cards benefit from a stronger boost.
    final contrastFactor = mean < 100 ? 1.2 : (mean < 180 ? 1.5 : 1.8);

    image = img.adjustColor(image, contrast: contrastFactor);

    // Mild sharpening via convolution — improves thin-font card text
    image = img.convolution(image, filter: [
      0, -0.5,  0,
     -0.5,  3, -0.5,
      0, -0.5,  0,
    ], div: 1, offset: 0);

    return img.encodePng(image);
  }

  Future<String> saveImagePermanently(String tempPath, String contactId, String side) async {
    final bytes = await File(tempPath).readAsBytes();
    return saveCardImage(bytes, contactId, side);
  }

  Future<String> saveCardImage(Uint8List imageBytes, String contactId, String side) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(dir.path, 'card_images'));
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

    final filename = '${contactId}_${side}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(path.join(imagesDir.path, filename));
    await file.writeAsBytes(imageBytes);
    return file.path;
  }
}
