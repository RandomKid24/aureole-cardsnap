import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum BeforthButtonVariant { primary, secondary, ghost, ghostLight }

class BeforthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BeforthButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  const BeforthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BeforthButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide borderSide;

    switch (variant) {
      case BeforthButtonVariant.primary:
        bgColor = AppTheme.primaryBlue;
        textColor = AppTheme.white;
        borderSide = BorderSide.none;
        break;
      case BeforthButtonVariant.secondary:
        bgColor = AppTheme.navy;
        textColor = AppTheme.white;
        borderSide = BorderSide.none;
        break;
      case BeforthButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = AppTheme.navy;
        borderSide = const BorderSide(color: AppTheme.borderDivider);
        break;
      case BeforthButtonVariant.ghostLight:
        bgColor = Colors.transparent;
        textColor = AppTheme.white;
        borderSide = BorderSide(color: AppTheme.white.withValues(alpha: 0.5));
        break;
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        minimumSize: const Size(120, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: borderSide,
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: textColor, strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
    );
  }
}
