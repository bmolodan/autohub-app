import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Master theme for the NESEMOS AutoHub customer app.
///
/// Wire it into MaterialApp like this:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light(),
///   // darkTheme: AppTheme.dark(),  // not implemented yet — brand is light-first
///   ...
/// )
/// ```
///
/// Required dependency in pubspec.yaml:
/// ```yaml
/// dependencies:
///   google_fonts: ^6.2.1
/// ```
class AppTheme {
  AppTheme._();

  /// Light theme — primary brand experience.
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.brandYellow,
      onPrimary: AppColors.onYellow,
      primaryContainer: AppColors.brandYellowSoft,
      onPrimaryContainer: AppColors.brandBlack,
      secondary: AppColors.brandBlack,
      onSecondary: AppColors.onBlack,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.border,
      outlineVariant: AppColors.borderStrong,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.border,
      splashFactory: InkRipple.splashFactory,
      // iOS-style right-to-left slide on both platforms — matches the brand
      // feel and the existing back-swipe gesture.
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      }),
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),

      // ─── App bars ────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge,
        iconTheme: const IconThemeData(
            color: AppColors.textPrimary, size: AppIconSize.lg),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // ─── Cards ───────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        clipBehavior: Clip.antiAlias,
      ),

      // ─── Buttons ─────────────────────────────────────────────────
      // Primary CTA — yellow pill
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandYellow,
          foregroundColor: AppColors.onYellow,
          disabledBackgroundColor: AppColors.surfaceVariant,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size(double.infinity, AppSizes.ctaMinHeight),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.btnH, vertical: AppSpacing.btnV),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.pillAll),
          elevation: 0,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      // Secondary CTA — black pill (used for "Записатись", utility actions)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandBlack,
          foregroundColor: AppColors.onBlack,
          minimumSize: const Size(double.infinity, AppSizes.ctaMinHeight),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.btnH, vertical: AppSpacing.btnV),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.pillAll),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      // Outlined / tertiary
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderStrong, width: 0.5),
          minimumSize: const Size(double.infinity, AppSizes.ctaMinHeight),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.btnH, vertical: AppSpacing.btnV),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.pillAll),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      // Text-only
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          textStyle: AppTypography.labelMedium,
        ),
      ),

      // ─── Inputs ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.inputH, vertical: AppSpacing.inputV),
        hintStyle:
            AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
        labelStyle:
            AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        floatingLabelStyle:
            AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.brandYellow, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: AppColors.error, width: 1.0),
        ),
      ),

      // ─── Chips ───────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.brandYellow,
        secondarySelectedColor: AppColors.brandBlack,
        disabledColor: AppColors.surfaceVariant,
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle:
            AppTypography.labelMedium.copyWith(color: AppColors.onBlack),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.chipH, vertical: AppSpacing.chipV),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.pillAll),
        side: BorderSide.none,
      ),

      // ─── Bottom navigation ───────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textDisabled,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ─── Switches (notifications) ────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandBlack;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandYellow;
          }
          return AppColors.borderStrong;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ─── Dividers ────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
        space: 0,
      ),

      // ─── Icons ───────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppIconSize.md,
      ),

      // ─── Dialogs ─────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
        titleTextStyle: AppTypography.headlineSmall,
        contentTextStyle:
            AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
      ),

      // ─── Snackbars ───────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.brandBlack,
        contentTextStyle:
            AppTypography.bodyMedium.copyWith(color: AppColors.onBlack),
        actionTextColor: AppColors.brandYellow,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
