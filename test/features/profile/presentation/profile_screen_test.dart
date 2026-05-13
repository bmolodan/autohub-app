import 'package:autohub/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_helpers/test_app.dart';

void main() {
  group('ProfileScreen', () {
    testWidgets('renders profile sections + edit icon', (tester) async {
      await pumpScreen(tester, child: const ProfileScreen());
      await tester.pumpAndSettle();

      expect(find.text('Профіль'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.text('Сповіщення'), findsOneWidget);
      expect(find.text('Підтримка'), findsOneWidget);
    });
  });
}
