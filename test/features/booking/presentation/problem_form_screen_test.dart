import 'package:autohub/features/booking/presentation/problem_form_screen.dart';
import 'package:autohub/features/orders/composition/orders_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_helpers/fakes.dart';
import '../../../_helpers/test_app.dart';

void main() {
  group('ProblemFormScreen', () {
    testWidgets('renders 3 empty photo slots and submit', (tester) async {
      await pumpScreen(
        tester,
        child: const ProblemFormScreen(serviceId: 'oil_change'),
        overrides: [
          activeOrderRepositoryProvider
              .overrideWithValue(FakeActiveOrderRepository()),
          photoStorageProvider.overrideWithValue(FakePhotoStorage()),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Що сталось?'), findsOneWidget);
      expect(find.text('Фото (0 / 3)'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNWidgets(3));
      expect(find.widgetWithText(ElevatedButton, 'Підтвердити запис'),
          findsOneWidget);
    });

    testWidgets('summary row shows service title from the catalog',
        (tester) async {
      await pumpScreen(
        tester,
        child: const ProblemFormScreen(serviceId: 'tires'),
        overrides: [
          activeOrderRepositoryProvider
              .overrideWithValue(FakeActiveOrderRepository()),
          photoStorageProvider.overrideWithValue(FakePhotoStorage()),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Шиномонтаж'), findsOneWidget);
    });

    testWidgets('tapping empty slot opens the camera/gallery bottom sheet',
        (tester) async {
      await pumpScreen(
        tester,
        child: const ProblemFormScreen(serviceId: 'oil_change'),
        overrides: [
          activeOrderRepositoryProvider
              .overrideWithValue(FakeActiveOrderRepository()),
          photoStorageProvider.overrideWithValue(FakePhotoStorage()),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      expect(find.text('Камера'), findsOneWidget);
      expect(find.text('Галерея'), findsOneWidget);
      expect(find.text('Скасувати'), findsOneWidget);
    });
  });
}
