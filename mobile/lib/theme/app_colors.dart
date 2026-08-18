import 'package:flutter/material.dart';

/// Tokens from the Escrow ET web design system (Figma: deep red, white/black).
abstract final class AppColors {
  static const brand = Color(0xFFC00000);
  static const brandHover = Color(0xFFA80000);
  static const brandActive = Color(0xFF8F0000);
  static const brandSoft = Color(0x14C00000);

  static const lightBg = Color(0xFFF8F8F8);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF666666);
  static const lightTextH = Color(0xFF111111);
  static const lightMuted = Color(0xFF8A8A8A);
  static const lightBorder = Color(0xFFE5E5E5);
  static const lightInput = Color(0xFFFFFFFF);

  static const darkBrand = Color(0xFFFF4D4D);
  static const darkBrandHover = Color(0xFFFF6666);
  static const darkBg = Color(0xFF000000);
  static const darkSurface = Color(0xFF0A0A0A);
  static const darkText = Color(0xFFA3A3A3);
  static const darkTextH = Color(0xFFFFFFFF);
  static const darkMuted = Color(0xFF808080);
  static const darkBorder = Color(0xFF252525);
  static const darkInput = Color(0xFF0F0F0F);
}
