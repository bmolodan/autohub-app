import 'package:flutter/material.dart';

/// NESEMOS AutoHub brand colors.
///
/// Brand reference: nesemosautohub.com
/// Primary: warm mustard yellow #F0CC50
/// Surface: cream #FAF9F6 + white #FFFFFF
/// Foreground: near-black #1A1A1A
class AppColors {
  AppColors._();

  // ─── Brand ──────────────────────────────────────────────────────────
  /// Mustard yellow — used for CTAs, active states, accents.
  static const Color brandYellow = Color(0xFFF0CC50);

  /// Slightly darker yellow for hover/pressed.
  static const Color brandYellowDark = Color(0xFFE0B940);

  /// Yellow tint background (e.g. info banners).
  static const Color brandYellowSoft = Color(0x33F0CC50); // 20% alpha

  /// Near-black — used for text, dark CTAs, icons.
  static const Color brandBlack = Color(0xFF1A1A1A);

  // ─── Surfaces ───────────────────────────────────────────────────────
  /// App background — warm cream.
  static const Color background = Color(0xFFFAF9F6);

  /// Card / elevated surface — pure white.
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle surface variant for inactive chips, dividers, soft fills.
  static const Color surfaceVariant = Color(0xFFF5F3EE);

  // ─── Text ──────────────────────────────────────────────────────────
  /// Primary body & heading text.
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary text — captions, metadata.
  static const Color textSecondary = Color(0xFF666666);

  /// Tertiary text — placeholder, muted labels.
  static const Color textTertiary = Color(0xFF888888);

  /// Disabled / very low emphasis text.
  static const Color textDisabled = Color(0xFFBBBBBB);

  // ─── Borders ───────────────────────────────────────────────────────
  /// Default hairline border / divider.
  static const Color border = Color(0xFFE5E2DD);

  /// Stronger border — focused inputs, dashed placeholders.
  static const Color borderStrong = Color(0xFFC8C5BD);

  // ─── Semantic ──────────────────────────────────────────────────────
  /// Error / destructive actions.
  static const Color error = Color(0xFFC04545);

  /// Soft error background.
  static const Color errorSoft = Color(0x1AC04545); // 10% alpha

  /// Foreground color on top of [error] (destructive button text).
  static const Color onError = Color(0xFFFFFFFF);

  /// Success / completed states.
  static const Color success = Color(0xFF1D9E75);

  /// Warning.
  static const Color warning = Color(0xFFE0A040);

  // ─── On-color helpers ──────────────────────────────────────────────
  /// Foreground color when sitting on top of [brandYellow].
  static const Color onYellow = Color(0xFF1A1A1A);

  /// Foreground color when sitting on top of [brandBlack].
  static const Color onBlack = Color(0xFFFFFFFF);

  /// Foreground for yellow-on-black emphasis (e.g. dark cards with yellow text).
  static const Color onBlackAccent = brandYellow;
}
