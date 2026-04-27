import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'confidence_dot.dart';

class FieldTile extends StatelessWidget {
  final String label;
  final String initialValue;
  final double confidence;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final int maxLines;

  const FieldTile({
    super.key,
    required this.label,
    required this.initialValue,
    required this.confidence,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final bool lowConf = confidence < 0.65 && confidence > 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.stone,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              if (confidence > 0) ConfidenceDot(confidence: confidence),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: initialValue,
            onChanged: onChanged,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.inter(fontSize: 16, color: AppTheme.navy, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: lowConf ? AppTheme.error : AppTheme.borderDivider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: lowConf ? AppTheme.error : AppTheme.borderDivider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: lowConf ? AppTheme.error : AppTheme.primaryBlue, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
