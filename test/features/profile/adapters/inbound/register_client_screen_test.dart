import 'package:autohub/features/profile/adapters/inbound/register_client_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/test_app.dart';

void main() {
  group('RegisterClientScreen', () {
    testWidgets('renders form + continue button', (tester) async {
      await pumpScreen(tester, child: const RegisterClientScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Як до вас звертатись'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Імʼя'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email (необовʼязково)'),
          findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Продовжити'), findsOneWidget);
    });

    testWidgets('submitting empty name surfaces required error',
        (tester) async {
      await pumpScreen(tester, child: const RegisterClientScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Продовжити'));
      await tester.pumpAndSettle();

      expect(find.text('Обовʼязкове поле'), findsOneWidget);
    });

    testWidgets('invalid email surfaces invalid error', (tester) async {
      await pumpScreen(tester, child: const RegisterClientScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Імʼя'), 'B');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email (необовʼязково)'),
          'not-an-email');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Продовжити'));
      await tester.pumpAndSettle();

      expect(find.text('Перевірте email'), findsOneWidget);
    });
  });
}
