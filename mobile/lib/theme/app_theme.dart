import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return _base(
      brightness: Brightness.light,
      brand: AppColors.crimson,
      title: AppColors.lightPrimary,
      bg: AppColors.lightBg,
      surface: AppColors.lightSurface,
      text: AppColors.lightText,
      textH: AppColors.lightTextH,
      muted: AppColors.lightMuted,
      border: AppColors.lightBorder,
      input: AppColors.lightSurface,
      navUnselected: AppColors.lightMuted,
    );
  }

  static ThemeData dark() {
    return _base(
      brightness: Brightness.dark,
      brand: AppColors.crimson,
      title: AppColors.darkPrimary,
      bg: AppColors.darkBg,
      surface: AppColors.darkSurface,
      text: AppColors.darkText,
      textH: AppColors.darkTextH,
      muted: AppColors.darkMuted,
      border: AppColors.darkBorder.withValues(alpha: 0.35),
      input: AppColors.darkContainer,
      navUnselected: AppColors.darkMuted,
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required Color brand,
    required Color title,
    required Color bg,
    required Color surface,
    required Color text,
    required Color textH,
    required Color muted,
    required Color border,
    required Color input,
    required Color navUnselected,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: brand,
      onPrimary: AppColors.snow,
      secondary: title,
      onSecondary: brightness == Brightness.dark ? AppColors.darkOnPrimary : AppColors.snow,
      error: brand,
      onError: AppColors.snow,
      surface: surface,
      onSurface: textH,
      outline: border,
    );

    final display = GoogleFonts.geistTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );
    final body = GoogleFonts.hankenGroteskTextTheme(display);
    final textTheme = body.apply(bodyColor: text, displayColor: textH);

    const radius = 4.0;
    const cardRadius = 12.0;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textH,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.geist(
          color: title,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: input,
        hintStyle: TextStyle(color: muted.withValues(alpha: 0.7), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: brand, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: brand),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: brightness == Brightness.dark
            ? AppColors.darkContainer.withValues(alpha: 0.94)
            : AppColors.snow,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.geist(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.4,
            color: selected ? AppColors.crimson : navUnselected,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.crimson : navUnselected,
            size: 22,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: AppColors.snow,
          disabledBackgroundColor: brand.withValues(alpha: 0.55),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
          textStyle: GoogleFonts.geist(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textH,
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
          textStyle: GoogleFonts.geist(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand,
          textStyle: GoogleFonts.geist(fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: border,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: border),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: brand.withValues(alpha: 0.1),
        side: BorderSide(color: border),
        labelStyle: GoogleFonts.geist(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}
