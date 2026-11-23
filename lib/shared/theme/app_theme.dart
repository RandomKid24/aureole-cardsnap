import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// BeForth Design System V2 — seven tokens, one accent, flat surfaces.
/// Names kept from the old theme so screens don't need rewiring.
class AppTheme {
  static const Color primaryBlue = Color(0xFF1C75BC); // signal
  static const Color signalDeep = Color(0xFF165B93); // hover / pressed
  static const Color wave = Color(0xFF75BAE6); // accent on dark only
  static const Color navy = Color(0xFF231F20); // ink
  static const Color deepNavy = Color(0xFF231F20); // ink (dark panels)
  static const Color slateBg = Color(0xFFF2F7F9); // paper
  static const Color white = Color(0xFFFFFFFF);
  static const Color stone = Color(0xFF5F6571); // ash
  static const Color borderDivider = Color(0x1F231F20); // 1px rule, ink @ 12%
  static const Color blueTint = Color(0xFFD6E7F1); // bone
  static const Color dotGrid = Color(0xFFD6E7F1); // unused (no grids)

  // Semantic status colours sit outside the brand palette by design.
  static const Color error = Color(0xFFD94F3D);
  static const Color warning = Color(0xFFE8A020);
  static const Color success = Color(0xFF2E7D52);

  static ThemeData get light {
    final baseText = GoogleFonts.plusJakartaSansTextTheme();
    TextStyle jak(double size, FontWeight w, Color c, {double ls = 0}) =>
        GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: c, letterSpacing: ls);
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: slateBg,
      primaryColor: primaryBlue,
      dividerColor: borderDivider,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: navy,
        surface: white,
        error: error,
      ),
      textTheme: baseText.copyWith(
        displayLarge: jak(40, FontWeight.w800, navy, ls: -1.4),
        displayMedium: jak(26, FontWeight.w800, navy, ls: -0.8),
        displaySmall: jak(20, FontWeight.w700, navy, ls: -0.4),
        titleLarge: jak(20, FontWeight.w600, navy, ls: -0.3),
        titleMedium: jak(16, FontWeight.w600, navy, ls: -0.2),
        bodyLarge: jak(16, FontWeight.w400, navy),
        bodyMedium: jak(14, FontWeight.w400, stone),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: slateBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: navy),
        centerTitle: false,
        titleTextStyle: jak(22, FontWeight.w700, navy, ls: -0.5),
      ),
      cardTheme: const CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: borderDivider),
        ),
      ),
    );
  }
}
