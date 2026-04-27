import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1A5BFF);
  static const Color navy = Color(0xFF0D1117);
  static const Color deepNavy = Color(0xFF1C2333);
  static const Color slateBg = Color(0xFFEDF0F8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color stone = Color(0xFF6B7280);
  static const Color borderDivider = Color(0xFFD1D8E8);
  static const Color blueTint = Color(0xFFEBF0FF);
  static const Color dotGrid = Color(0xFFC2CEE8);
  
  static const Color error = Color(0xFFD94F3D);
  static const Color warning = Color(0xFFE8A020);
  static const Color success = Color(0xFF2E7D52);

  static ThemeData get light {
    final baseText = GoogleFonts.interTextTheme();
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: slateBg,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: navy,
        surface: white,
        error: error,
      ),
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.bebasNeue(fontSize: 48, color: navy),
        displayMedium: GoogleFonts.bebasNeue(fontSize: 32, color: navy),
        displaySmall: GoogleFonts.bebasNeue(fontSize: 24, color: navy),
        titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: navy),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: navy),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: navy),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: stone),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: slateBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: navy),
        centerTitle: false,
        titleTextStyle: GoogleFonts.bebasNeue(fontSize: 28, color: navy, letterSpacing: 1.2),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDivider),
        ),
      ),
    );
  }
}
