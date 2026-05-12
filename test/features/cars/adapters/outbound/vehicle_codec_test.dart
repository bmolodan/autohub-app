import 'package:autohub/features/cars/adapters/outbound/vehicle_codec.dart';
import 'package:autohub/features/cars/domain/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

const _camry = Vehicle(
  id: 'v-camry',
  make: 'Toyota',
  model: 'Camry',
  year: 2018,
  plate: 'AA 1234 BC',
  vin: 'JT2BG28K3X0123456',
  mileageKm: 87500,
  nextServiceMileageKm: 90000,
);

const _bmw = Vehicle(
  id: 'v-bmw',
  make: 'BMW',
  model: '320i',
  year: 2020,
  plate: 'BB 7777 BB',
  vin: null,
  mileageKm: 0,
  nextServiceMileageKm: null,
);

void main() {
  group('vehicle_codec', () {
    test('round-trips a single vehicle with all fields populated', () {
      final encoded = encodeVehicles([_camry]);
      final decoded = decodeVehicles(encoded);
      expect(decoded.single, _camry);
      expect(decoded.single.vin, _camry.vin);
      expect(decoded.single.nextServiceMileageKm, _camry.nextServiceMileageKm);
    });

    test('round-trips a vehicle with nullable VIN + nextServiceMileageKm', () {
      final encoded = encodeVehicles([_bmw]);
      final decoded = decodeVehicles(encoded);
      expect(decoded.single, _bmw);
      expect(decoded.single.vin, isNull);
      expect(decoded.single.nextServiceMileageKm, isNull);
    });

    test('round-trips a list preserving order', () {
      final encoded = encodeVehicles([_camry, _bmw]);
      final decoded = decodeVehicles(encoded);
      expect(decoded.map((v) => v.id), ['v-camry', 'v-bmw']);
    });

    test('decode of empty array returns empty list', () {
      expect(decodeVehicles('[]'), isEmpty);
    });
  });
}
