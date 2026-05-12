import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography scale matching the AutoHub brand.
///
/// Font: Inter (geometric sans-serif). Closest free match to nesemosautohub.com.
/// If you want to swap to Manrope / custom font — change [_base] only.
///
/// Two weights only:
///   - 400 (regular) — body, captions
///   - 500 (medium) — headings, CTAs, emphasis
///
/// Cases:
///   - Title Case / sentence case for headings ("Коли вам зручно?")
///   - UPPERCASE with letterSpacing 1–2 for micro-labels & badges ("У РОБОТІ")
class AppTypography {
  AppTypography._();

  static TextStyle _base({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double height = 1.4,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // ─── Display / hero numbers (28+) ──────────────────────────────────
  static TextStyle get displayLarge =>
      _base(size: 32, weight: FontWeight.w500, height: 1.1);
  static TextStyle get displayMedium =>
      _base(size: 28, weight: FontWeight.w500, height: 1.1);

  // ─── Headlines (page titles, big questions) ────────────────────────
  static TextStyle get headlineLarge =>
      _base(size: 24, weight: FontWeight.w500, height: 1.2);
  static TextStyle get headlineMedium =>
      _base(size: 22, weight: FontWeight.w500, height: 1.2);
  static TextStyle get headlineSmall =>
      _base(size: 20, weight: FontWeight.w500, height: 1.25);

  // ─── Titles (card headers, section labels) ─────────────────────────
  static TextStyle get titleLarge =>
      _base(size: 16, weight: FontWeight.w500, height: 1.3);
  static TextStyle get titleMedium =>
      _base(size: 14, weight: FontWeight.w500, height: 1.3);
  static TextStyle get titleSmall =>
      _base(size: 12, weight: FontWeight.w500, height: 1.3);

  // ─── Body ──────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => _base(size: 14, height: 1.5);
  static TextStyle get bodyMedium => _base(size: 12, height: 1.5);
  static TextStyle get bodySmall =>
      _base(size: 11, height: 1.5, color: AppColors.textSecondary);

  // ─── Labels (buttons, chips, ALL CAPS micro labels) ────────────────
  static TextStyle get labelLarge =>
      _base(size: 14, weight: FontWeight.w500, height: 1.2);
  static TextStyle get labelMedium =>
      _base(size: 12, weight: FontWeight.w500, height: 1.2);
  static TextStyle get labelSmall => _base(
        size: 10,
        weight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 1.5,
        color: AppColors.textSecondary,
      );

  /// Tiny ALL CAPS label used as section header ("У РОБОТІ", "ІСТОРІЯ").
  /// Always rendered with [Text(label.toUpperCase(), …)].
  static TextStyle get overline => _base(
        size: 10,
        weight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 1.8,
        color: AppColors.textSecondary,
      );

  /// Captions in mute tone — for metadata under titles.
  static TextStyle get caption =>
      _base(size: 10, height: 1.4, color: AppColors.textTertiary);

  // ─── Aggregate TextTheme for ThemeData ─────────────────────────────
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
