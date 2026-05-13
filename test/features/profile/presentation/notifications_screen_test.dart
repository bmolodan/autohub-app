import 'package:autohub/features/profile/presentation/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_helpers/test_app.dart';

void main() {
  group('NotificationsScreen', () {
    testWidgets('renders the 5 toggle tiles', (tester) async {
      await pumpScreen(tester, child: const NotificationsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Що надсилати?'), findsOneWidget);
      // 4 push categories + 1 quiet-hours switch = 5 tiles.
      expect(find.byType(Switch), findsNWidgets(5));
    });

    testWidgets('tapping a switch flips its state', (tester) async {
      await pumpScreen(tester, child: const NotificationsScreen());
      await tester.pumpAndSettle();

      final firstSwitch = find.byType(Switch).first;
      final before = tester.widget<Switch>(firstSwitch).value;

      await tester.tap(firstSwitch);
      await tester.pumpAndSettle();

      final after = tester.widget<Switch>(firstSwitch).value;
      expect(after, !before);
    });
  });
}
