import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/theme/app_theme.dart';

import 'image_processor.dart';
import 'ocr_service.dart';
import '../parse/local_parser.dart';
import '../parse/confidence_engine.dart';
import 'package:go_router/go_router.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isProcessing = false;
  String? _frontImagePath;
  String? _backImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionAndStart();
    });
  }

  Future<void> _checkPermissionAndStart() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Camera permission required.")));
        }
        return;
      }
    }
    _startScan();
  }

  Future<List<String>?> _captureCard() async {
    if (Platform.isAndroid) {
      try {
         return await _captureWithDocumentScanner();
      } catch (e) {
         final path = await _captureWithCameraFallback();
         return path != null ? [path] : null;
      }
    } else {
      final path = await _captureWithCameraFallback();
      return path != null ? [path] : null;
    }
  }

  Future<List<String>?> _captureWithDocumentScanner() async {
    final documentScanner = DocumentScanner(
      options: DocumentScannerOptions(
        mode: ScannerMode.full,
        pageLimit: 2,
      ),
    );

    final result = await documentScanner.scanDocument();
    await documentScanner.close();
    return (result.images?.isEmpty ?? true) ? null : result.images!;
  }

  Future<String?> _captureWithCameraFallback() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 90,
    );
    if (photo == null) return null;

    final cropped = await ImageCropper().cropImage(
      sourcePath: photo.path,
      aspectRatio: const CropAspectRatio(ratioX: 85.6, ratioY: 53.98),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop to card edges',
          toolbarColor: AppTheme.primaryBlue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop to card edges',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    return cropped?.path;
  }

  Future<void> _startScan() async {
    if (_isProcessing) return;

    try {
      final imagePaths = await _captureCard();
      if (imagePaths != null && imagePaths.isNotEmpty) {
        HapticFeedback.mediumImpact();

        setState(() {
          _frontImagePath = imagePaths[0];
          if (imagePaths.length > 1) {
            _backImagePath = imagePaths[1];
          }
        });
        
        await _processAndNavigate();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Capture failed.")));
      }
    }
  }

  Future<void> _processAndNavigate() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final imageProcessor = ImageProcessor();
      final ocrService = OcrService.instance;
      final localParser = LocalParser();
      final confidenceEngine = ConfidenceEngine();

      final processedFront =
          await imageProcessor.processImage(_frontImagePath!);
      final ocrBlocks = await ocrService.recognizeText(processedFront);

      var parseResult = localParser.parse(ocrBlocks);

      if (mounted) {
        await confidenceEngine.saveDraftAndNavigate(
            context, parseResult, _frontImagePath, _backImagePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Processing failed. Please try again.")));
      }
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
        children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.contact_page_outlined,
                    color: Colors.white24,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "SCAN FRONT SIDE",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 2.0,
                        ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          if (!_isProcessing)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _checkPermissionAndStart,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ),
            ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                        color: AppTheme.primaryBlue),
                    const SizedBox(height: 24),
                    Text(
                      "EXTRACTING DETAILS...",
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            ),
          ),
        ],
      ),
    ));
  }
}
