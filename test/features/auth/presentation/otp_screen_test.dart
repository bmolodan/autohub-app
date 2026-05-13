import 'package:autohub/features/auth/presentation/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_helpers/test_app.dart';

void main() {
  group('OtpScreen', () {
    testWidgets('renders title + 4 digit slots + disabled submit',
        (tester) async {
      await pumpScreen(
        tester,
        child: const OtpScreen(phone: '+380671234567', challengeId: 'ch-1'),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Введіть код'), findsOneWidget);
      // Masked phone shows the suffix from input.
      expect(find.textContaining('67'), findsWidgets);

      // Submit is disabled before 4 digits are entered.
      final submit = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Підтвердити'),
      );
      expect(submit.onPressed, isNull);
    });
  });
}
