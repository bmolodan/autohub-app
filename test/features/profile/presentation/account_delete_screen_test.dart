import 'package:autohub/features/profile/presentation/account_delete_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_helpers/test_app.dart';

void main() {
  group('AccountDeleteScreen', () {
    testWidgets('renders heading, list of items being deleted, and 2 CTAs',
        (tester) async {
      await pumpScreen(tester, child: const AccountDeleteScreen());
      await tester.pumpAndSettle();

      expect(find.text('Видалити акаунт?'), findsOneWidget);
      // Three items being wiped.
      expect(find.text('Профіль і авто'), findsOneWidget);
      expect(find.text('Історія обслуговування'), findsOneWidget);
      expect(find.text('Push-сповіщення'), findsOneWidget);
      // Both CTAs visible.
      expect(
          find.widgetWithText(ElevatedButton, 'Так, видалити'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Скасувати'), findsOneWidget);
    });
  });
}
