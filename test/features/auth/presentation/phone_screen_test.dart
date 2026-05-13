import 'package:autohub/features/auth/presentation/phone_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_helpers/test_app.dart';

void main() {
  group('PhoneScreen', () {
    testWidgets('renders the greeting + +380 prefix + disabled submit',
        (tester) async {
      await pumpScreen(tester, child: const PhoneScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Вітаємо'), findsOneWidget);
      expect(find.text('+380'), findsOneWidget);
      // Submit is disabled with empty input.
      final submit = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Надіслати код'),
      );
      expect(submit.onPressed, isNull);
    });

    testWidgets('typing a 9-digit number enables submit', (tester) async {
      await pumpScreen(tester, child: const PhoneScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '671234567');
      await tester.pump();

      final submit = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Надіслати код'),
      );
      expect(submit.onPressed, isNotNull);
    });
  });
}
