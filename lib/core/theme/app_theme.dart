import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';

class AppTheme {
  static ThemeData get warmTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      primaryColor: AppColors.primary,
      useMaterial3: true,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.bgCard,
        background: AppColors.bgPrimary,
        onPrimary: Colors.white,
        onSurface: AppColors.textDark,
      ),

      // DM Serif Display for headings — editorial luxury feel
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: AppDimensions.fontHero,
          color: AppColors.textDark,
          fontWeight: FontWeight.w400,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.dmSerifDisplay(
          fontSize: AppDimensions.fontXXL,
          color: AppColors.textDark,
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.dmSerifDisplay(
          fontSize: AppDimensions.fontXL,
          color: AppColors.textDark,
          fontWeight: FontWeight.w400,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: AppDimensions.fontLG,
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: AppDimensions.fontMD,
          color: AppColors.textDark,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: AppDimensions.fontSM,
          color: AppColors.textMid,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: AppDimensions.fontXS,
          color: AppColors.textLight,
          letterSpacing: 0.5,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: AppDimensions.fontMD,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          elevation: 0,
        ),
      ),
    );
  }
 }