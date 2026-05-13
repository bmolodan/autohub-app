import 'package:autohub/features/booking/presentation/booking_screen.dart';
import 'package:autohub/features/cars/composition/cars_providers.dart';
import 'package:autohub/features/cars/domain/vehicle.dart';
import 'package:autohub/features/orders/composition/orders_providers.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../_helpers/fakes.dart';
import '../../../_helpers/test_app.dart';

List<Override> _defaults({List<Vehicle> vehicles = const []}) => [
      vehicleRepositoryProvider
          .overrideWithValue(FakeVehicleRepository(seed: vehicles)),
      activeOrderRepositoryProvider
          .overrideWithValue(FakeActiveOrderRepository()),
    ];

const _camry = Vehicle(
  id: 'v-1',
  make: 'Toyota',
  model: 'Camry',
  year: 2018,
  plate: 'AA 1234 BC',
  vin: null,
  mileageKm: 0,
  nextServiceMileageKm: null,
);

void main() {
  group('BookingScreen', () {
    testWidgets(
        'renders single-screen layout with description + photo + vehicle + date',
        (tester) async {
      await pumpScreen(
        tester,
        child: const BookingScreen(),
        overrides: _defaults(vehicles: [_camry]),
      );
      await tester.pumpAndSettle();

      // Heading
      expect(find.text('Що сталось?'), findsOneWidget);
      // Vehicle section + tile with the seeded car
      expect(find.text('АВТО'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('2018 · AA 1234 BC'), findsOneWidget);
      // Date section with "Найближчий час" selected by default + the pick CTA
      expect(find.text('БАЖАНА ДАТА'), findsOneWidget);
      expect(find.text('Найближчий час'), findsOneWidget);
      expect(find.text('Обрати дату й час'), findsOneWidget);
      // Submit CTA
      expect(find.text('Підтвердити запис'), findsOneWidget);
    });

    testWidgets('empty-vehicles tile shows the add-a-car fallback prompt',
        (tester) async {
      // The empty-vehicles entry point routes via Home → /cars/add and
      // shouldn't actually land here in production. This test guards the
      // defensive fallback render so the screen doesn't crash.
      await pumpScreen(
        tester,
        child: const BookingScreen(),
        overrides: _defaults(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Спочатку додайте авто'), findsOneWidget);
    });
  });
}
