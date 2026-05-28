import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg           = Color(0xFF120D08);
  static const bgSurface    = Color(0xFF1E1610);
  static const bgCard       = Color(0xFF241A11);
  static const bgBorder     = Color(0xFF2E2018);
  static const amber        = Color(0xFFC8823A);
  static const amberLight   = Color(0xFFF0D9B5);
  static const textPrimary   = Color(0xFFF0D9B5);
  static const textSecondary = Color(0xFFC4A882);
  static const textMuted     = Color(0xFF8A6A4A);
  static const textFaint     = Color(0xFF5A4535);
  static const textGhost     = Color(0xFF3D2E1E);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.amber,
      secondary: AppColors.amberLight,
      surface: AppColors.bgSurface,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 20, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.lora(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary, height: 1.85,
      ),
      bodyMedium: GoogleFonts.lora(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.sourceSans3(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),
      labelSmall: GoogleFonts.sourceSans3(
        fontSize: 10, fontWeight: FontWeight.w400,
        color: AppColors.textFaint,
        letterSpacing: 0.8,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bg,
      selectedItemColor: AppColors.amber,
      unselectedItemColor: AppColors.textFaint,
    ),
  );
}
