import 'package:flutter/material.dart';

/// Crimson Matrix tokens from `DESIGN.md` (dark) and `DESIGN light.md`.
abstract final class AppColors {
  static const crimson = Color(0xFFE61919);
  static const onyx = Color(0xFF131313);
  static const snow = Color(0xFFFFFFFF);

  static const lightBg = Color(0xFFF9F9F9);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightMist = Color(0xFFF9F9F9);
  static const lightContainer = Color(0xFFEEEEEE);
  static const lightText = Color(0xFF5E3F3B);
  static const lightTextH = Color(0xFF1A1C1C);
  static const lightMuted = Color(0xFF5F5E5E);
  static const lightBorder = Color(0xFFE5E5E5);
  static const lightPrimary = Color(0xFFBC000A);
  static const lightPlaceholder = Color(0xFFA0A0A0);

  static const darkBg = Color(0xFF131313);
  static const darkSurface = Color(0xFF1C1B1B);
  static const darkContainer = Color(0xFF20201F);
  static const darkContainerHigh = Color(0xFF2A2A2A);
  static const darkText = Color(0xFFE8BCB6);
  static const darkTextH = Color(0xFFE5E2E1);
  static const darkMuted = Color(0xFFC9C6C5);
  static const darkBorder = Color(0xFFAE8782);
  static const darkPrimary = Color(0xFFFFB4AA);
  static const darkOnPrimary = Color(0xFF690003);

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
