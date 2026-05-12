import 'package:autohub/core/storage/shared_prefs_provider.dart';
import 'package:autohub/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App starts at onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const AutoHubApp(),
      ),
    );
    await tester.pumpAndSettle();

    // First onboarding slide should be visible.
    expect(find.text('Далі'), findsOneWidget);
    expect(find.text('Пропустити'), findsOneWidget);
  });
}
