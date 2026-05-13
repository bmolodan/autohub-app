import 'package:autohub/features/booking/presentation/service_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_helpers/test_app.dart';

void main() {
  group('ServicePickerScreen', () {
    testWidgets('lists all 5 catalog services', (tester) async {
      await pumpScreen(tester, child: const ServicePickerScreen());

      expect(find.text('Заміна масла'), findsOneWidget);
      expect(find.text('Шиномонтаж'), findsOneWidget);
      expect(find.text('Діагностика двигуна'), findsOneWidget);
      expect(find.text('Гальмівна система'), findsOneWidget);
      expect(find.text('Кондиціонер'), findsOneWidget);
    });

    testWidgets('search field filters the list by title', (tester) async {
      await pumpScreen(tester, child: const ServicePickerScreen());

      await tester.enterText(find.byType(TextField), 'масла');
      await tester.pump();

      expect(find.text('Заміна масла'), findsOneWidget);
      expect(find.text('Шиномонтаж'), findsNothing);
      expect(find.text('Кондиціонер'), findsNothing);
    });

    testWidgets('"Далі" button is disabled until a service is picked',
        (tester) async {
      await pumpScreen(tester, child: const ServicePickerScreen());

      final dali = find.widgetWithText(FilledButton, 'Далі');
      expect(dali, findsOneWidget);
      expect(
        tester.widget<FilledButton>(dali).onPressed,
        isNull,
      );

      await tester.tap(find.text('Заміна масла'));
      await tester.pump();

      expect(
        tester.widget<FilledButton>(dali).onPressed,
        isNotNull,
      );
    });

    testWidgets('shows the "name it yourself" CTA below the list',
        (tester) async {
      await pumpScreen(tester, child: const ServicePickerScreen());

      expect(find.text('Не знайшли? Назвіть послугу самі'), findsOneWidget);
    });

    testWidgets('custom CTA opens a sheet with a name field + submit',
        (tester) async {
      await pumpScreen(tester, child: const ServicePickerScreen());

      await tester.tap(find.text('Не знайшли? Назвіть послугу самі'));
      await tester.pumpAndSettle();

      expect(find.text('Власна послуга'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Продовжити'), findsOneWidget);
    });

    testWidgets('custom sheet submit with empty text does not navigate',
        (tester) async {
      await pumpScreen(tester, child: const ServicePickerScreen());

      await tester.tap(find.text('Не знайшли? Назвіть послугу самі'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Продовжити'));
      await tester.pumpAndSettle();

      // Sheet stays open (no nav happened) — title still visible.
      expect(find.text('Власна послуга'), findsOneWidget);
    });
  });
}
