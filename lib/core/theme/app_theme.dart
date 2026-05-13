import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_radii.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'brand_colors.dart';

/// Master theme for the NESEMOS AutoHub customer app.
///
/// Wire it into MaterialApp like this:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light(),
///   darkTheme: AppTheme.dark(),
///   themeMode: ThemeMode.system,
///   ...
/// )
/// ```
class AppTheme {
  AppTheme._();

  /// Light theme — primary brand experience.
  static ThemeData light() => _buildTheme(BrandColors.light(), Brightness.light);

  /// Dark theme — mirrors the light theme with the dark `BrandColors`
  /// palette. Brand yellow stays identical; cream / black / borders
  /// invert.
  static ThemeData dark() => _buildTheme(BrandColors.dark(), Brightness.dark);

  static ThemeData _buildTheme(BrandColors c, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.brandYellow,
      onPrimary: c.onYellow,
      primaryContainer: c.brandYellowSoft,
      onPrimaryContainer: c.brandBlack,
      secondary: c.brandBlack,
      onSecondary: c.onBlack,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surfaceVariant,
      onSurfaceVariant: c.textSecondary,
      error: c.error,
      onError: c.onError,
      outline: c.border,
      outlineVariant: c.borderStrong,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[c],
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.border,
      splashFactory: InkRipple.splashFactory,
      // iOS-style right-to-left slide on both platforms — matches the brand
      // feel and the existing back-swipe gesture.
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      }),
      textTheme: AppTypography.textTheme.apply(
        bodyColor: c.textPrimary,
        displayColor: c.textPrimary,
      ),

      // ─── App bars ────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: c.textPrimary),
        iconTheme: IconThemeData(color: c.textPrimary, size: AppIconSize.lg),
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // ─── Cards ───────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        clipBehavior: Clip.antiAlias,
      ),

      // ─── Buttons ─────────────────────────────────────────────────
      // Primary CTA — yellow pill
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.brandYellow,
          foregroundColor: c.onYellow,
          disabledBackgroundColor: c.surfaceVariant,
          disabledForegroundColor: c.textDisabled,
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
          backgroundColor: c.brandBlack,
          foregroundColor: c.onBlack,
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
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.borderStrong, width: 0.5),
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
          foregroundColor: c.textPrimary,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          textStyle: AppTypography.labelMedium,
        ),
      ),

      // ─── Inputs ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.inputH, vertical: AppSpacing.inputV),
        hintStyle: AppTypography.bodyMedium.copyWith(color: c.textTertiary),
        labelStyle: AppTypography.bodySmall.copyWith(color: c.textSecondary),
        floatingLabelStyle:
            AppTypography.labelSmall.copyWith(color: c.textSecondary),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: c.brandYellow, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: BorderSide(color: c.error, width: 1.0),
        ),
      ),

      // ─── Chips ───────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.brandYellow,
        secondarySelectedColor: c.brandBlack,
        disabledColor: c.surfaceVariant,
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle:
            AppTypography.labelMedium.copyWith(color: c.onBlack),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.chipH, vertical: AppSpacing.chipV),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.pillAll),
        side: BorderSide.none,
      ),

      // ─── Bottom navigation ───────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.background,
        selectedItemColor: c.textPrimary,
        unselectedItemColor: c.textDisabled,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ─── Switches (notifications) ────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return c.brandBlack;
          }
          return brightness == Brightness.dark ? c.surface : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return c.brandYellow;
          }
          return c.borderStrong;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ─── Dividers ────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: 0.5,
        space: 0,
      ),

      // ─── Icons ───────────────────────────────────────────────────
      iconTheme: IconThemeData(color: c.textPrimary, size: AppIconSize.md),

      // ─── Dialogs ─────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
        titleTextStyle: AppTypography.headlineSmall.copyWith(color: c.textPrimary),
        contentTextStyle:
            AppTypography.bodyLarge.copyWith(color: c.textSecondary),
      ),

      // ─── Snackbars ───────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.brandBlack,
        contentTextStyle:
            AppTypography.bodyMedium.copyWith(color: c.onBlack),
        actionTextColor: c.brandYellow,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
