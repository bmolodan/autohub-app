import 'package:autohub/features/cars/adapters/inbound/cars_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/test_app.dart';

void main() {
  group('CarsListScreen', () {
    testWidgets('renders the seeded Toyota Camry from the composition',
        (tester) async {
      await pumpScreen(tester, child: const CarsListScreen());
      await tester.pumpAndSettle();

      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.textContaining('AA 1234 BC'), findsOneWidget);
    });

    testWidgets('shows the "Додати авто" CTA', (tester) async {
      await pumpScreen(tester, child: const CarsListScreen());
      await tester.pumpAndSettle();

      expect(find.text('Додати авто'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
