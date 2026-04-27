import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConfidenceDot extends StatelessWidget {
  final double confidence;

  const ConfidenceDot({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (confidence >= 0.8) {
      color = AppTheme.success;
    } else if (confidence >= 0.65) {
      color = AppTheme.warning;
    } else {
      color = AppTheme.error;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
