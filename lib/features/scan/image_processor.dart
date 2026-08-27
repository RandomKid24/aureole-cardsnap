import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

import '../../core/config/parser_config.dart';

class ImageProcessor {
  Future<String> processImage(String imagePath, {bool alreadyCorrected = false}) async {
    final bytes = await File(imagePath).readAsBytes();

    final processedBytes = await compute(
      _processAndEncodeImage,
      (bytes, alreadyCorrected),
    );

    final tempDir = await getTemporaryDirectory();
    final processedPath = path.join(
      tempDir.path,
      'temp_processed_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await File(processedPath).writeAsBytes(processedBytes);
    return processedPath;
  }

  Future<double> computeQualityScore(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return compute(_computeQualityScore, bytes);
  }

  static Uint8List _processAndEncodeImage((Uint8List, bool) args) {
    final bytes = args.$1;
    final alreadyCorrected = args.$2;

    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception("Could not decode image");

    image = _applyExifRotation(image);

    // The ML Kit document scanner already rectifies, crops and deskews. Re-running
    // perspective correction + the multi-angle deskew search on top of that is
    // wasted CPU (often a second or more) and can distort an already-clean crop.
    if (!alreadyCorrected) {
      final corrected = _tryPerspectiveCorrection(image);
      if (corrected != null) image = corrected;
    }

    image = _smartResize(image);
    if (!alreadyCorrected) {
      image = _deskew(image);
    }

    // Light contrast boost only — ML Kit handles its own preprocessing
    final grayscale = img.grayscale(image);
    final pixels = grayscale.getBytes(order: img.ChannelOrder.rgb);
    final mean = pixels.fold<int>(0, (s, b) => s + b) / pixels.length;
    if (mean < 100 || mean > 200) {
      image = img.adjustColor(image, contrast: 1.2);
    }

    return img.encodePng(image);
  }

  static double _computeQualityScore(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return 0.0;

    double score = 0.0;

    // Resolution score (0.0 - 0.3)
    final pixelCount = image.width * image.height;
    final minPixels = 500 * 500;
    final idealPixels = 1500 * 1500;
    if (pixelCount >= idealPixels) {
      score += 0.3;
    } else if (pixelCount >= minPixels) {
      score += 0.3 * (pixelCount / idealPixels);
    } else {
      score += 0.3 * (pixelCount / minPixels) * 0.5;
    }

    // Contrast score (0.0 - 0.35)
    final grayscale = img.grayscale(img.copyResize(image, width: 200));
    final gPixels = grayscale.getBytes(order: img.ChannelOrder.rgb);
    final gMean = gPixels.fold<int>(0, (s, b) => s + b) / gPixels.length;
    final variance = gPixels.fold<double>(0, (s, b) => s + (b - gMean) * (b - gMean)) / gPixels.length;
    final stdDev = sqrt(variance);
    final contrastScore = (stdDev / 60.0).clamp(0.0, 1.0);
    score += 0.35 * contrastScore;

    // Sharpness score via Laplacian variance (0.0 - 0.35)
    final small = img.grayscale(img.copyResize(image, width: 200));
    final laplacian = _computeLaplacianVariance(small);
    final sharpnessScore = (laplacian / 500.0).clamp(0.0, 1.0);
    score += 0.35 * sharpnessScore;

    return score.clamp(0.0, 1.0);
  }

  static double _computeLaplacianVariance(img.Image grayscale) {
    final w = grayscale.width;
    final h = grayscale.height;
    if (w < 3 || h < 3) return 0.0;

    final pixels = grayscale.getBytes(order: img.ChannelOrder.rgb);
    final laplacian = <double>[];

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final idx = (y * w + x) * 3;
        final center = pixels[idx].toDouble();
        final top = pixels[((y - 1) * w + x) * 3].toDouble();
        final bottom = pixels[((y + 1) * w + x) * 3].toDouble();
        final left = pixels[(y * w + (x - 1)) * 3].toDouble();
        final right = pixels[(y * w + (x + 1)) * 3].toDouble();
        laplacian.add(-4 * center + top + bottom + left + right);
      }
    }

    if (laplacian.isEmpty) return 0.0;
    final mean = laplacian.fold<double>(0, (s, v) => s + v) / laplacian.length;
    return laplacian.fold<double>(0, (s, v) => s + (v - mean) * (v - mean)) / laplacian.length;
  }

  static img.Image _applyExifRotation(img.Image image) {
    // The image package auto-rotates based on EXIF when decoding.
    // If it doesn't (some formats), we detect via dimensions.
    // Business cards are wider than tall — if taller, likely rotated.
    if (image.height > image.width * 1.3) {
      return img.copyRotate(image, angle: 90);
    }
    return image;
  }

  /// Best-effort perspective correction for unaligned card photos.
  /// Returns null if corner detection fails — caller falls through to existing deskew.
  static img.Image? _tryPerspectiveCorrection(img.Image image) {
    final maxDim = max(image.width, image.height);
    final scale = maxDim > 800 ? 800.0 / maxDim : 1.0;
    final small = scale < 1.0
        ? img.copyResize(image,
            width: (image.width * scale).round(),
            height: (image.height * scale).round(),
            interpolation: img.Interpolation.linear)
        : image;

    final gray = img.grayscale(small);
    final w = gray.width;
    final h = gray.height;
    if (w < 10 || h < 10) return null;

    // Compute edge map: gradient magnitude at each pixel
    final edgeMap = List.generate(h, (_) => List.filled(w, 0.0));
    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final p = gray.getPixel(x, y).r.toDouble();
        final right = gray.getPixel(x + 1, y).r.toDouble();
        final bottom = gray.getPixel(x, y + 1).r.toDouble();
        edgeMap[y][x] = (p - right).abs() + (p - bottom).abs();
      }
    }

    // Adaptive threshold: mean + 1.5 * stddev of edge strengths
    double edgeSum = 0, edgeSumSq = 0;
    int edgeCount = 0;
    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final v = edgeMap[y][x];
        if (v > 0) {
          edgeSum += v;
          edgeSumSq += v * v;
          edgeCount++;
        }
      }
    }
    if (edgeCount < 50) return null;
    final edgeMean = edgeSum / edgeCount;
    final edgeVariance = edgeSumSq / edgeCount - edgeMean * edgeMean;
    final edgeStdDev = edgeVariance > 0 ? sqrt(edgeVariance) : 0.0;
    final threshold = edgeMean + 1.5 * edgeStdDev;

    // Find center of mass of strong edge pixels
    double cx = 0, cy = 0;
    int strongCount = 0;
    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        if (edgeMap[y][x] > threshold) {
          cx += x;
          cy += y;
          strongCount++;
        }
      }
    }
    if (strongCount < 20) return null;
    cx /= strongCount;
    cy /= strongCount;

    // Find the farthest strong edge pixel in each quadrant from center
    double tlScore = 0, trScore = 0, blScore = 0, brScore = 0;
    int tlX = 0, tlY = 0, trX = 0, trY = 0;
    int blX = 0, blY = 0, brX = 0, brY = 0;

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        if (edgeMap[y][x] <= threshold) continue;
        final dx = x - cx;
        final dy = y - cy;
        final dist = dx * dx + dy * dy;
        if (dx <= 0 && dy <= 0 && dist > tlScore) {
          tlScore = dist; tlX = x; tlY = y;
        } else if (dx > 0 && dy <= 0 && dist > trScore) {
          trScore = dist; trX = x; trY = y;
        } else if (dx <= 0 && dy > 0 && dist > blScore) {
          blScore = dist; blX = x; blY = y;
        } else if (dx > 0 && dy > 0 && dist > brScore) {
          brScore = dist; brX = x; brY = y;
        }
      }
    }

    // Require all 4 corners to be found with minimum spread
    final minCornerDist = (min(w, h) * 0.15);
    if (tlScore < minCornerDist * minCornerDist ||
        trScore < minCornerDist * minCornerDist ||
        blScore < minCornerDist * minCornerDist ||
        brScore < minCornerDist * minCornerDist) {
      return null;
    }

    // Validate convexity via cross products of adjacent edges
    if (!_isConvexQuad(tlX, tlY, trX, trY, brX, brY, blX, blY)) return null;

    // Validate area: quadrilateral area should be > 30% of image area
    final quadArea = _quadArea(tlX, tlY, trX, trY, brX, brY, blX, blY);
    if (quadArea < w * h * 0.3) return null;

    // Scale coordinates back to full resolution
    double s = 1.0 / scale;
    return img.copyRectify(
      image,
      topLeft: img.Point(tlX * s, tlY * s),
      topRight: img.Point(trX * s, trY * s),
      bottomLeft: img.Point(blX * s, blY * s),
      bottomRight: img.Point(brX * s, brY * s),
      interpolation: img.Interpolation.linear,
    );
  }

  static bool _isConvexQuad(
      int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4) {
    // Check that cross products of all adjacent edge pairs have the same sign
    int prevSign = 0;
    final points = [(x1, y1), (x2, y2), (x3, y3), (x4, y4)];
    for (int i = 0; i < 4; i++) {
      final (ax, ay) = points[i];
      final (bx, by) = points[(i + 1) % 4];
      final (cx, cy) = points[(i + 2) % 4];
      final cross = (bx - ax) * (cy - by) - (by - ay) * (cx - bx);
      if (cross == 0) return false;
      final sign = cross > 0 ? 1 : -1;
      if (prevSign != 0 && sign != prevSign) return false;
      prevSign = sign;
    }
    return true;
  }

  static double _quadArea(
      int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4) {
    // Shoelace formula for quadrilateral area
    return 0.5 * ((x1 * y2 + x2 * y3 + x3 * y4 + x4 * y1) -
        (y1 * x2 + y2 * x3 + y3 * x4 + y4 * x1)).abs();
  }

  static img.Image _smartResize(img.Image image) {
    final maxW = ParserConfig.maxImageWidth;
    final maxH = ParserConfig.maxImageHeight;

    if (image.width <= maxW && image.height <= maxH) {
      return image;
    }

    final ratio = min(maxW / image.width, maxH / image.height);
    final newW = (image.width * ratio).round();
    final newH = (image.height * ratio).round();

    return img.copyResize(
      image,
      width: newW,
      height: newH,
      interpolation: img.Interpolation.linear,
    );
  }

  static img.Image _deskew(img.Image image) {
    // Detect skew via horizontal edge projection
    // Convert to grayscale for edge detection
    final gray = img.grayscale(img.copyResize(image, width: 300));

    // Build horizontal projection profile at multiple angles
    double bestAngle = 0;
    double bestVariance = 0;

    for (double angle = -ParserConfig.deskewAngleLimit;
        angle <= ParserConfig.deskewAngleLimit;
        angle += 0.5) {
      final rotated = img.copyRotate(gray, angle: angle);
      final rPixels = rotated.getBytes(order: img.ChannelOrder.rgb);
      final rW = rotated.width;
      final rH = rotated.height;

      // Horizontal projection: sum of edge pixels per row
      final projection = List<double>.filled(rH, 0);
      for (int y = 0; y < rH; y++) {
        double rowSum = 0;
        for (int x = 1; x < rW; x++) {
          final idx = (y * rW + x) * 3;
          final prev = rPixels[(y * rW + (x - 1)) * 3];
          final curr = rPixels[idx];
          rowSum += (curr - prev).abs();
        }
        projection[y] = rowSum;
      }

      // Variance of projection — higher = more aligned text lines
      final mean = projection.fold<double>(0, (s, v) => s + v) / projection.length;
      final variance = projection.fold<double>(0, (s, v) => s + (v - mean) * (v - mean)) / projection.length;

      if (variance > bestVariance) {
        bestVariance = variance;
        bestAngle = angle;
      }
    }

    // Only apply if angle is meaningful (not near 0)
    if (bestAngle.abs() < 0.5) return image;

    return img.copyRotate(image, angle: bestAngle);
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
