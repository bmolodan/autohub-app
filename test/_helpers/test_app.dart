import 'package:autohub/core/storage/shared_prefs_provider.dart';
import 'package:autohub/core/theme/app_theme.dart';
import 'package:autohub/core/util/clock.dart';
import 'package:autohub/core/util/id_generator.dart';
import 'package:autohub/features/auth/composition/auth_providers.dart';
import 'package:autohub/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'in_memory_session_storage.dart';

/// Pumps [child] inside a fully-configured `MaterialApp` + `ProviderScope`
/// with deterministic Clock/IdGenerator overrides and a mock-backed
/// SharedPreferences. Extra [overrides] are appended.
///
/// Default surface size mimics iPhone 13/14 (390x844 logical px) — better
/// fit for Column-heavy screens than the Flutter test default of 800x600.
/// Pass [surfaceSize] to test other breakpoints.
Future<void> pumpScreen(
  WidgetTester tester, {
  required Widget child,
  List<Override> overrides = const [],
  Map<String, Object> initialPrefs = const {},
  Size surfaceSize = const Size(390, 844),
  Locale locale = const Locale('uk'),
  Brightness brightness = Brightness.light,
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sessionStorageProvider.overrideWithValue(InMemorySessionStorage()),
        clockProvider.overrideWithValue(FixedClock(DateTime.utc(2026, 5, 13))),
        idGeneratorProvider.overrideWithValue(CountingIdGenerator()),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode:
            brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}
