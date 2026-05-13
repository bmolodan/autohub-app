import 'package:autohub/features/booking/presentation/problem_form_screen.dart';
import 'package:autohub/features/cars/composition/cars_providers.dart';
import 'package:autohub/features/cars/domain/vehicle.dart';
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

    testWidgets('vehicle row is not tappable with a single car',
        (tester) async {
      await pumpScreen(
        tester,
        child: const ProblemFormScreen(serviceId: 'oil_change'),
        overrides: [
          activeOrderRepositoryProvider
              .overrideWithValue(FakeActiveOrderRepository()),
          photoStorageProvider.overrideWithValue(FakePhotoStorage()),
          vehicleRepositoryProvider.overrideWithValue(
            FakeVehicleRepository(seed: const [
              Vehicle(
                id: 'v1',
                make: 'Toyota',
                model: 'Camry',
                year: 2018,
                plate: 'AA 1234 BC',
                vin: null,
                mileageKm: 80000,
                nextServiceMileageKm: null,
              ),
            ]),
          ),
        ],
      );
      await tester.pumpAndSettle();

      // Summary value visible, no chevron next to it.
      expect(find.text('Toyota Camry'), findsOneWidget);
      // Only the appbar back arrow uses chevron-like icons; no chevron_right.
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('vehicle row opens picker sheet and switches car',
        (tester) async {
      await pumpScreen(
        tester,
        child: const ProblemFormScreen(serviceId: 'oil_change'),
        overrides: [
          activeOrderRepositoryProvider
              .overrideWithValue(FakeActiveOrderRepository()),
          photoStorageProvider.overrideWithValue(FakePhotoStorage()),
          vehicleRepositoryProvider.overrideWithValue(
            FakeVehicleRepository(seed: const [
              Vehicle(
                id: 'v1',
                make: 'Toyota',
                model: 'Camry',
                year: 2018,
                plate: 'AA 1234 BC',
                vin: null,
                mileageKm: 80000,
                nextServiceMileageKm: null,
              ),
              Vehicle(
                id: 'v2',
                make: 'Honda',
                model: 'Civic',
                year: 2020,
                plate: 'BB 5678 CD',
                vin: null,
                mileageKm: 30000,
                nextServiceMileageKm: null,
              ),
            ]),
          ),
        ],
      );
      await tester.pumpAndSettle();

      // Default selection.
      expect(find.text('Toyota Camry'), findsOneWidget);

      // Tap the chevron-decorated vehicle row to open the sheet.
      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();

      // Sheet has both cars.
      expect(find.text('Honda Civic'), findsOneWidget);

      // Pick Honda.
      await tester.tap(find.text('Honda Civic'));
      await tester.pumpAndSettle();

      // Summary now shows Honda.
      expect(find.text('Honda Civic'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsNothing);
    });
  });
}
