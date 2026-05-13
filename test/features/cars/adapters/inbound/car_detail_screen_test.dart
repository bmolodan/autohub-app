import 'package:autohub/features/cars/adapters/inbound/car_detail_screen.dart';
import 'package:autohub/features/cars/composition/cars_providers.dart';
import 'package:autohub/features/cars/domain/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/fakes.dart';
import '../../../../_helpers/test_app.dart';

const _bmw = Vehicle(
  id: 'v-bmw-1',
  make: 'BMW',
  model: 'X5',
  year: 2020,
  plate: 'BB 4242 BB',
  vin: null,
  mileageKm: 30000,
  nextServiceMileageKm: null,
);

List<Override> _overrides() => [
      vehicleRepositoryProvider
          .overrideWithValue(FakeVehicleRepository(seed: const [_bmw])),
    ];

void main() {
  group('CarDetailScreen', () {
    testWidgets('renders BMW X5 with edit + delete app-bar icons',
        (tester) async {
      await pumpScreen(
        tester,
        child: const CarDetailScreen(vehicleId: 'v-bmw-1'),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('BMW X5'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('tapping delete shows confirmation dialog with No + Yes',
        (tester) async {
      await pumpScreen(
        tester,
        child: const CarDetailScreen(vehicleId: 'v-bmw-1'),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Видалити авто?'), findsOneWidget);
      expect(find.text('Ні'), findsOneWidget);
      expect(find.text('Так, видалити'), findsOneWidget);
    });

    testWidgets('confirming delete removes the car', (tester) async {
      final fake = FakeVehicleRepository(seed: const [_bmw]);
      await pumpScreen(
        tester,
        child: const CarDetailScreen(vehicleId: 'v-bmw-1'),
        overrides: [
          vehicleRepositoryProvider.overrideWithValue(fake),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Так, видалити'));
      await tester.pumpAndSettle();

      expect(await fake.findAll(), isEmpty);
    });
  });
}
