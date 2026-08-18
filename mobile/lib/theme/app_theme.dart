import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return _base(
      brightness: Brightness.light,
      brand: AppColors.brand,
      brandHover: AppColors.brandHover,
      bg: AppColors.lightBg,
      surface: AppColors.lightSurface,
      text: AppColors.lightText,
      textH: AppColors.lightTextH,
      muted: AppColors.lightMuted,
      border: AppColors.lightBorder,
      input: AppColors.lightInput,
    );
  }

  static ThemeData dark() {
    return _base(
      brightness: Brightness.dark,
      brand: AppColors.darkBrand,
      brandHover: AppColors.darkBrandHover,
      bg: AppColors.darkBg,
      surface: AppColors.darkSurface,
      text: AppColors.darkText,
      textH: AppColors.darkTextH,
      muted: AppColors.darkMuted,
      border: AppColors.darkBorder,
      input: AppColors.darkInput,
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required Color brand,
    required Color brandHover,
    required Color bg,
    required Color surface,
    required Color text,
    required Color textH,
    required Color muted,
    required Color border,
    required Color input,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: brand,
      onPrimary: Colors.white,
      secondary: brand,
      onSecondary: Colors.white,
      error: brand,
      onError: Colors.white,
      surface: surface,
      onSurface: textH,
      outline: border,
    );

    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: text, displayColor: textH);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textH,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: textH,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: input,
        hintStyle: TextStyle(color: muted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: brand),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brand,
        foregroundColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: brand.withValues(alpha: 0.55),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor: WidgetStatePropertyAll(brandHover.withValues(alpha: 0.2)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brand,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: brand),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: border,
      chipTheme: ChipThemeData(
        selectedColor: brand.withValues(alpha: 0.12),
        side: BorderSide(color: border),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
