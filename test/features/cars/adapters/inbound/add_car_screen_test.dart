import 'package:autohub/features/cars/adapters/inbound/add_car_screen.dart';
import 'package:autohub/features/cars/composition/cars_providers.dart';
import 'package:autohub/features/cars/data/car_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/fakes.dart';
import '../../../../_helpers/test_app.dart';

const _catalog = CarCatalog({
  'BMW': ['320i', 'M3', 'X5'],
  'Toyota': ['Camry', 'Corolla'],
});

List<Override> _overrides() => [
      carCatalogPortProvider.overrideWithValue(FakeCarCatalogPort(_catalog)),
    ];

void main() {
  group('AddCarScreen', () {
    testWidgets('shows form fields and submit button', (tester) async {
      await pumpScreen(tester,
          child: const AddCarScreen(), overrides: _overrides());
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
      await pumpScreen(tester,
          child: const AddCarScreen(), overrides: _overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Зберегти авто'));
      await tester.pumpAndSettle();

      // At least one "Обовʼязкове поле" error appears for make/model/plate.
      expect(find.text('Обовʼязкове поле'), findsWidgets);
    });

    testWidgets('tapping Make field opens picker sheet with searchable list',
        (tester) async {
      await pumpScreen(tester,
          child: const AddCarScreen(), overrides: _overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextFormField, 'Марка'));
      await tester.pumpAndSettle();

      expect(find.text('BMW'), findsOneWidget);
      expect(find.text('Toyota'), findsOneWidget);

      await tester.tap(find.text('BMW'));
      await tester.pumpAndSettle();

      // Make field now reflects selection.
      final makeField = tester
          .widget<TextFormField>(find.widgetWithText(TextFormField, 'Марка'));
      expect(makeField.controller!.text, 'BMW');
    });

    testWidgets('model picker is filtered to the picked make', (tester) async {
      await pumpScreen(tester,
          child: const AddCarScreen(), overrides: _overrides());
      await tester.pumpAndSettle();

      // Pick BMW first.
      await tester.tap(find.widgetWithText(TextFormField, 'Марка'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BMW'));
      await tester.pumpAndSettle();

      // Now open model picker — should show BMW models only.
      await tester.tap(find.widgetWithText(TextFormField, 'Модель'));
      await tester.pumpAndSettle();

      expect(find.text('320i'), findsOneWidget);
      expect(find.text('M3'), findsOneWidget);
      expect(find.text('Camry'), findsNothing);
    });

    testWidgets('plate formatter normalizes lowercase + Cyrillic input',
        (tester) async {
      await pumpScreen(tester,
          child: const AddCarScreen(), overrides: _overrides());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Номер'), 'аа1234вв');
      await tester.pumpAndSettle();

      // Field shows formatted Latin uppercase with spaces.
      final plateField = tester
          .widget<TextFormField>(find.widgetWithText(TextFormField, 'Номер'));
      expect(plateField.controller!.text, 'AA 1234 BB');
    });

    testWidgets('implausible year shows range error', (tester) async {
      await pumpScreen(tester,
          child: const AddCarScreen(), overrides: _overrides());
      await tester.pumpAndSettle();

      // Pick BMW + 320i via the sheets.
      await tester.tap(find.widgetWithText(TextFormField, 'Марка'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BMW'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextFormField, 'Модель'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('320i'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Рік'), '1800');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Номер'), 'BB 4242 BB');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Зберегти авто'));
      await tester.pumpAndSettle();

      expect(find.textContaining('1900'), findsOneWidget);
    });
  });
}
