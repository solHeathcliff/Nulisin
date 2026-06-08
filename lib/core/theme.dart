import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF062E23);
  static const Color onPrimary = Colors.white;
  static const Color surface = Color(0xFFF4F7F5);
  static const Color surfaceBright = Color(0xFFF9F9F7);
  static const Color background = Color(0xFFF9F9F7);
  static const Color onSurface = Color(0xFF1A1C1B);
  static const Color onSurfaceVariant = Color(0xFF58605B);
  static const Color outline = Color(0xFFE0E8E1);
  static const Color outlineVariant = Color(0xFFC1C8C3);
  static const Color secondary = Color(0xFF58605B);
  static const Color secondaryContainer = Color(0xFFDCE5DE);
  static const Color sage = Color(0xFFE0E8E1);
  static const Color cardBackground = Colors.white;
  static const Color error = Color(0xFFBA1A1A);
}

class AppTextStyles {
  static TextStyle get displayLg => GoogleFonts.sourceSerif4(
        fontSize: 36, fontWeight: FontWeight.w700, height: 1.2,
        color: AppColors.onSurface);

  static TextStyle get headlineLg => GoogleFonts.sourceSerif4(
        fontSize: 28, fontWeight: FontWeight.w600, height: 1.3,
        color: AppColors.onSurface);

  static TextStyle get headlineMd => GoogleFonts.sourceSerif4(
        fontSize: 22, fontWeight: FontWeight.w600, height: 1.4,
        color: AppColors.onSurface);

  static TextStyle get headlineSm => GoogleFonts.sourceSerif4(
        fontSize: 18, fontWeight: FontWeight.w600, height: 1.4,
        color: AppColors.onSurface);

  static TextStyle get bodyLg => GoogleFonts.hankenGrotesk(
        fontSize: 18, fontWeight: FontWeight.w400, height: 1.6,
        color: AppColors.onSurface);

  static TextStyle get bodyMd => GoogleFonts.hankenGrotesk(
        fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
        color: AppColors.onSurface);

  static TextStyle get labelLg => GoogleFonts.hankenGrotesk(
        fontSize: 14, fontWeight: FontWeight.w600, height: 1.4,
        letterSpacing: 0.6, color: AppColors.onSurface);

  static TextStyle get labelSm => GoogleFonts.hankenGrotesk(
        fontSize: 12, fontWeight: FontWeight.w500, height: 1.4,
        color: AppColors.onSurfaceVariant);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surfaceBright,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.hankenGroteskTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceBright,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.sourceSerif4(
          fontSize: 22, fontWeight: FontWeight.w700,
          color: AppColors.primary, letterSpacing: -0.3),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.hankenGrotesk(fontSize: 15, color: AppColors.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
          elevation: 0,
          textStyle: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
          textStyle: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
