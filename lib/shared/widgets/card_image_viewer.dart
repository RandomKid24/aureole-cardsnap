import 'dart:io';
import 'package:flutter/material.dart';

/// Full-screen, pinch-to-zoom viewer for the scanned card photo(s).
/// Pass the front path and (optionally) the back path; swipe to switch.
void showCardImageViewer(BuildContext context, {required String front, String? back}) {
  final paths = [
    front,
    if (back != null && back.isNotEmpty && File(back).existsSync()) back,
  ];
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => _CardImageViewer(paths: paths),
  ));
}

class _CardImageViewer extends StatelessWidget {
  const _CardImageViewer({required this.paths});
  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(paths.length > 1 ? 'Front · swipe for back' : 'Scanned card'),
      ),
      body: PageView(
        children: [
          for (final p in paths)
            InteractiveViewer(
              minScale: 1,
              maxScale: 6,
              child: Center(child: Image.file(File(p), fit: BoxFit.contain)),
            ),
        ],
      ),
    );
  }
}
