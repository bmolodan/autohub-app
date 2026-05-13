import 'package:autohub/features/cars/adapters/inbound/add_car_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/test_app.dart';

void main() {
  group('AddCarScreen', () {
    testWidgets('shows form fields and submit button', (tester) async {
      await pumpScreen(tester, child: const AddCarScreen());
      await tester.pumpAndSettle();

      expect(find.text('Розкажіть про вашу машину'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Марка'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Модель'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Рік'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Номер'), findsOneWidget);
      expect(
          find.widgetWithText(ElevatedButton, 'Зберегти авто'), findsOneWidget);
    });

    testWidgets('empty submit shows validation errors', (tester) async {
      await pumpScreen(tester, child: const AddCarScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Зберегти авто'));
      await tester.pumpAndSettle();

      // At least one "Обовʼязкове поле" error appears for make/model/plate.
      expect(find.text('Обовʼязкове поле'), findsWidgets);
    });

    testWidgets('implausible year shows range error', (tester) async {
      await pumpScreen(tester, child: const AddCarScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Марка'), 'BMW');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Модель'), '320i');
      await tester.enterText(find.widgetWithText(TextFormField, 'Рік'), '1800');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Номер'), 'BB 4242 BB');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Зберегти авто'));
      await tester.pumpAndSettle();

      expect(find.textContaining('1900'), findsOneWidget);
    });
  });
}
