import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand palette exposed through `ThemeExtension`. The names mirror
/// the legacy `AppColors` static surface so consumers can swap in a
/// `BuildContext`-aware accessor without semantic drift:
///
/// ```dart
/// // before
/// color: AppColors.background
/// // after
/// color: context.colors.background
/// ```
///
/// Light values delegate to [AppColors] so the showcase / docs stay
/// in sync. Dark values are inversions tuned for the cream / mustard
/// brand on a near-black canvas.
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({
    required this.brandYellow,
    required this.brandYellowDark,
    required this.brandYellowSoft,
    required this.brandBlack,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.border,
    required this.borderStrong,
    required this.error,
    required this.errorSoft,
    required this.onError,
    required this.success,
    required this.warning,
    required this.onYellow,
    required this.onBlack,
    required this.onBlackAccent,
    required this.heroSurface,
    required this.onHeroSurface,
  });

  factory BrandColors.light() => const BrandColors(
        brandYellow: AppColors.brandYellow,
        brandYellowDark: AppColors.brandYellowDark,
        brandYellowSoft: AppColors.brandYellowSoft,
        brandBlack: AppColors.brandBlack,
        background: AppColors.background,
        surface: AppColors.surface,
        surfaceVariant: AppColors.surfaceVariant,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        textTertiary: AppColors.textTertiary,
        textDisabled: AppColors.textDisabled,
        border: AppColors.border,
        borderStrong: AppColors.borderStrong,
        error: AppColors.error,
        errorSoft: AppColors.errorSoft,
        onError: AppColors.onError,
        success: AppColors.success,
        warning: AppColors.warning,
        onYellow: AppColors.onYellow,
        onBlack: AppColors.onBlack,
        onBlackAccent: AppColors.onBlackAccent,
        // In light mode the in-progress hero card sits on `brandBlack`.
        heroSurface: AppColors.brandBlack,
        // Light: hero sits on brandBlack so foreground stays white.
        onHeroSurface: AppColors.onBlack,
      );

  factory BrandColors.dark() => const BrandColors(
        // Brand identity stays — yellow is the same on both modes.
        brandYellow: AppColors.brandYellow,
        brandYellowDark: AppColors.brandYellowDark,
        brandYellowSoft: AppColors.brandYellowSoft,
        // `brandBlack` is the "contrast anchor" — in dark mode it flips
        // to the lightest neutral so the FilledButton + avatar circle
        // keep their visual role.
        brandBlack: Color(0xFFF5F3EE),
        background: Color(0xFF0F0F0F),
        surface: Color(0xFF1A1A1A),
        surfaceVariant: Color(0xFF262626),
        textPrimary: Color(0xFFF5F3EE),
        textSecondary: Color(0xFF9A9A9A),
        textTertiary: Color(0xFF777777),
        textDisabled: Color(0xFF555555),
        border: Color(0xFF2A2A2A),
        borderStrong: Color(0xFF3A3A3A),
        error: AppColors.error,
        // Light-mode errorSoft (0x1A alpha) composites near-invisibly on
        // a near-black scaffold; bump to ~25% to keep the warning bubble
        // legible.
        errorSoft: Color(0x40C04545),
        onError: AppColors.onError,
        success: AppColors.success,
        warning: AppColors.warning,
        // Yellow chip still uses near-black foreground — yellow is bright.
        onYellow: AppColors.brandBlack,
        // The contrast anchor flipped to light, so its foreground flips
        // to near-black.
        onBlack: AppColors.brandBlack,
        onBlackAccent: AppColors.brandYellow,
        // Hero card on dark mode: a touch lighter than the scaffold so
        // it lifts off the background; a `brandBlack` card on a near-black
        // canvas would disappear.
        heroSurface: Color(0xFF262626),
        // Dark hero stays dark in dark mode → foreground stays cream.
        // Distinct from `onBlack` because brandBlack (the contrast anchor)
        // flipped to light, while heroSurface intentionally did not.
        onHeroSurface: Color(0xFFF5F3EE),
      );

  final Color brandYellow;
  final Color brandYellowDark;
  final Color brandYellowSoft;
  final Color brandBlack;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color border;
  final Color borderStrong;
  final Color error;
  final Color errorSoft;
  final Color onError;
  final Color success;
  final Color warning;
  final Color onYellow;
  final Color onBlack;
  final Color onBlackAccent;
  final Color heroSurface;
  final Color onHeroSurface;

  @override
  BrandColors copyWith({
    Color? brandYellow,
    Color? brandYellowDark,
    Color? brandYellowSoft,
    Color? brandBlack,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? border,
    Color? borderStrong,
    Color? error,
    Color? errorSoft,
    Color? onError,
    Color? success,
    Color? warning,
    Color? onYellow,
    Color? onBlack,
    Color? onBlackAccent,
    Color? heroSurface,
    Color? onHeroSurface,
  }) =>
      BrandColors(
        brandYellow: brandYellow ?? this.brandYellow,
        brandYellowDark: brandYellowDark ?? this.brandYellowDark,
        brandYellowSoft: brandYellowSoft ?? this.brandYellowSoft,
        brandBlack: brandBlack ?? this.brandBlack,
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceVariant: surfaceVariant ?? this.surfaceVariant,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
        textDisabled: textDisabled ?? this.textDisabled,
        border: border ?? this.border,
        borderStrong: borderStrong ?? this.borderStrong,
        error: error ?? this.error,
        errorSoft: errorSoft ?? this.errorSoft,
        onError: onError ?? this.onError,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        onYellow: onYellow ?? this.onYellow,
        onBlack: onBlack ?? this.onBlack,
        onBlackAccent: onBlackAccent ?? this.onBlackAccent,
        heroSurface: heroSurface ?? this.heroSurface,
        onHeroSurface: onHeroSurface ?? this.onHeroSurface,
      );

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      brandYellow: Color.lerp(brandYellow, other.brandYellow, t)!,
      brandYellowDark: Color.lerp(brandYellowDark, other.brandYellowDark, t)!,
      brandYellowSoft: Color.lerp(brandYellowSoft, other.brandYellowSoft, t)!,
      brandBlack: Color.lerp(brandBlack, other.brandBlack, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onYellow: Color.lerp(onYellow, other.onYellow, t)!,
      onBlack: Color.lerp(onBlack, other.onBlack, t)!,
      onBlackAccent: Color.lerp(onBlackAccent, other.onBlackAccent, t)!,
      heroSurface: Color.lerp(heroSurface, other.heroSurface, t)!,
      onHeroSurface: Color.lerp(onHeroSurface, other.onHeroSurface, t)!,
    );
  }
}

extension BrandColorsContext on BuildContext {
  /// Brightness-aware brand palette. Returns the light palette if the
  /// theme has no `BrandColors` extension (e.g. an in-test widget that
  /// forgot to wire `AppTheme.light()`).
  BrandColors get colors =>
      Theme.of(this).extension<BrandColors>() ?? BrandColors.light();
}
