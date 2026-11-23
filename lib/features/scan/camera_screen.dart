import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../core/database/database.dart';

import '../parse/parse_pipeline.dart';
import '../parse/confidence_engine.dart';
import 'package:go_router/go_router.dart';

enum ScanStep { front, backReady, processing }

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isProcessing = false;
  bool _capturing = false;
  String? _frontImagePath;
  String? _backImagePath;
  ScanStep _step = ScanStep.front;
  bool _hasAutoStarted = false;
  bool _usedDocumentScanner = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasAutoStarted) {
      _hasAutoStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkPermissionAndStart();
      });
    }
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
    _startCapture();
  }

  /// A [PlatformException] the ML Kit document scanner raises when the user
  /// backs out — must NOT be treated as a scanner failure (doing so used to
  /// bounce them into the system camera).
  static bool _isUserCancel(Object e) {
    final s = e.toString().toLowerCase();
    return s.contains('cancel');
  }

  Future<List<String>?> _captureCard() async {
    if (Platform.isAndroid) {
      try {
        _usedDocumentScanner = true;
        return await _captureWithDocumentScanner();
      } catch (e) {
        if (_isUserCancel(e)) return null; // user backed out — just leave
        // Genuine scanner failure → fall back to a plain camera + crop.
        debugPrint('CameraScreen: doc scanner failed, using camera fallback: $e');
        _usedDocumentScanner = false;
        final path = await _captureWithCameraFallback();
        return path != null ? [path] : null;
      }
    } else {
      _usedDocumentScanner = false;
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
    if (result.images == null || result.images!.isEmpty) return null;
    final validPaths = result.images!
        .where((p) => File(p).existsSync() && File(p).lengthSync() > 0)
        .toList();
    return validPaths.isEmpty ? null : validPaths;
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

  Future<void> _startCapture() async {
    if (_isProcessing || _capturing) return;

    setState(() => _capturing = true);
    try {
      final imagePaths = await _captureCard();
      if (imagePaths != null && imagePaths.isNotEmpty) {
        HapticFeedback.mediumImpact();
        setState(() {
          _frontImagePath = imagePaths[0];
          if (imagePaths.length > 1) {
            _backImagePath = imagePaths[1];
          }
          _step = ScanStep.backReady;
          _capturing = false;
        });
      } else {
        // Scanner dismissed without a capture — go straight back, no dead-end.
        if (mounted) context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Capture failed.")));
        context.go('/');
      }
    }
  }

  Future<void> _captureBack() async {
    if (_isProcessing) return;

    try {
      final imagePaths = await _captureCard();
      if (imagePaths != null && imagePaths.isNotEmpty) {
        HapticFeedback.mediumImpact();
        setState(() {
          _backImagePath = imagePaths[0];
        });
        _processAndNavigate();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Capture failed.")));
      }
    }
  }

  Future<void> _processAndNavigate() async {
    setState(() {
      _isProcessing = true;
      _step = ScanStep.processing;
    });

    try {
      final pipeline = await ParsePipeline.create(
        db: context.read<AppDatabase>(),
      );
      final result = await pipeline.process(
        _frontImagePath!,
        imagePathBack: _backImagePath,
        alreadyCorrected: _usedDocumentScanner,
      );

      if (mounted) {
        await ConfidenceEngine().saveDraftAndNavigate(
          context,
          result.parseResult,
          _frontImagePath,
          _backImagePath,
        );
      }
    } catch (e) {
      debugPrint('Processing failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Processing failed. Please try again.")));
        setState(() {
          _isProcessing = false;
          _step = ScanStep.front;
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
        context.go('/');
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_step == ScanStep.front) ...[
                    const CircularProgressIndicator(color: Colors.white24),
                  ] else if (_step == ScanStep.backReady) ...[
                    if (_frontImagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: Image.file(
                          File(_frontImagePath!),
                          width: 200,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Icon(Icons.check_circle, color: Colors.green, size: 32),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      "FRONT CAPTURED",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 2.0,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Scan back side or extract now",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ] else if (_isProcessing) ...[
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
                ],
              ),
            ),

            // Bottom controls — only for the "front captured, scan back?" step.
            if (_step == ScanStep.backReady && !_isProcessing)
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: _buildBottomControls(),
              ),

            // Close button
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => context.go('/'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: _captureBack,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 6),
                    const Text("Scan Back", style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _processAndNavigate,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
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
                        child: const Icon(Icons.check, color: Colors.white, size: 32),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text("Extract Now", style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
  }
}
