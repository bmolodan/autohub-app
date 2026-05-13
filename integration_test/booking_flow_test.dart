import 'dart:convert';

import 'package:autohub/core/storage/shared_prefs_provider.dart';
import 'package:autohub/core/util/clock.dart';
import 'package:autohub/core/util/id_generator.dart';
import 'package:autohub/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // The app hardcodes Locale('uk') in main.dart; string assertions below
  // depend on that. If that ever becomes dynamic, this test must set
  // tester.binding.platformDispatcher.localeTestValue or fail loudly.
  testWidgets('book a service → see pending order on home and detail',
      (tester) async {
    // Pre-seed a session so the router skips onboarding/phone/OTP and we
    // can focus on the booking + orders flow itself. Auth flow has its
    // own widget tests; integration covers the post-login path.
    SharedPreferences.setMockInitialValues({
      'session': jsonEncode({
        'phone': '+380671234567',
        'createdAt': DateTime.utc(2026, 5, 13).toIso8601String(),
      }),
    });
    addTearDown(() => SharedPreferences.setMockInitialValues({}));
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          clockProvider.overrideWithValue(
            FixedClock(DateTime.utc(2026, 5, 13, 12)),
          ),
          idGeneratorProvider.overrideWithValue(CountingIdGenerator()),
        ],
        child: const AutoHubApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1) Land on Home with the 2 seeded orders.
    expect(find.text('Богдане'), findsOneWidget);
    expect(find.text('У РЕМОНТІ'), findsOneWidget);
    expect(find.text('Очікує підтвердження'), findsOneWidget);

    // 2) Start booking.
    await tester.tap(find.widgetWithText(ElevatedButton, '+ Записатись'));
    await tester.pumpAndSettle();

    // 3) Pick the first service and continue to step 3/3.
    await tester.tap(find.text('Заміна масла'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Далі'));
    await tester.pumpAndSettle();

    // 4) Submit the booking.
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Підтвердити запис'),
    );
    await tester.pumpAndSettle();

    // 5) Lands on the order-detail screen with pending hero.
    expect(find.text('ОЧІКУЄ ПІДТВЕРДЖЕННЯ'), findsOneWidget);
    expect(find.text('Заміна масла'), findsOneWidget);
  });
}
