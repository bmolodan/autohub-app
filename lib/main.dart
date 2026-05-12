import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/storage/shared_prefs_provider.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_radii.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _wireGlobalErrorHandling();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const AutoHubApp(),
    ),
  );
}

void _wireGlobalErrorHandling() {
  // Framework-thrown errors (build/layout/paint).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Hook to Crashlytics/Sentry here when wired.
  };

  // Platform-thread async errors that don't propagate to the zone.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught platform error: $error\n$stack');
    return true;
  };

  // Branded fallback red-screen in release; default in debug.
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const _BrandedErrorWidget();
  }
}

class _BrandedErrorWidget extends StatelessWidget {
  const _BrandedErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(AppSpacing.lg),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.errorSoft,
              borderRadius: AppRadii.lgAll,
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Сталася помилка', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Перезапустіть застосунок.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AutoHubApp extends ConsumerWidget {
  const AutoHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'AutoHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      locale: const Locale('uk'),
      supportedLocales: const [Locale('uk'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
