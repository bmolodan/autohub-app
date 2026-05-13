import 'package:autohub/features/cars/adapters/outbound/http_vehicle_repository.dart';
import 'package:autohub/features/cars/domain/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/fake_http_adapter.dart';

const _camryJson = {
  'id': 'v-camry',
  'make': 'Toyota',
  'model': 'Camry',
  'year': 2018,
  'plate': 'AA 1234 BC',
  'vin': 'JT2BG28K3X0123456',
  'mileageKm': 87500,
  'nextServiceMileageKm': 90000,
};

void main() {
  group('HttpVehicleRepository.findAll', () {
    test('GETs /vehicles and decodes the array', () async {
      final adapter = FakeHttpAdapter(
        (req) => FakeResponse.json(200, [_camryJson]),
      );
      final repo = HttpVehicleRepository(dioWith(adapter));

      final out = await repo.findAll();

      expect(out, hasLength(1));
      expect(out.single.id, 'v-camry');
      expect(adapter.requests.single.method, 'GET');
      expect(adapter.requests.single.path, '/vehicles');
    });

    test('throws on 500', () async {
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 500, body: 'boom'),
      );
      final repo = HttpVehicleRepository(dioWith(adapter));

      expect(repo.findAll(), throwsA(anything));
    });
  });

  group('HttpVehicleRepository.findById', () {
    test('GETs /vehicles/<id> and decodes', () async {
      final adapter = FakeHttpAdapter(
        (req) => FakeResponse.json(200, _camryJson),
      );
      final repo = HttpVehicleRepository(dioWith(adapter));

      final out = await repo.findById('v-camry');

      expect(out, isNotNull);
      expect(out!.make, 'Toyota');
      expect(adapter.requests.single.path, '/vehicles/v-camry');
    });

    test('returns null on 404', () async {
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 404, body: ''),
      );
      final repo = HttpVehicleRepository(dioWith(adapter));

      expect(await repo.findById('missing'), isNull);
    });
  });

  group('HttpVehicleRepository.save', () {
    test('POSTs JSON-encoded vehicle to /vehicles', () async {
      final adapter = FakeHttpAdapter(
        (req) => FakeResponse.json(201, _camryJson),
      );
      final repo = HttpVehicleRepository(dioWith(adapter));

      const vehicle = Vehicle(
        id: 'v-camry',
        make: 'Toyota',
        model: 'Camry',
        year: 2018,
        plate: 'AA 1234 BC',
        vin: 'JT2BG28K3X0123456',
        mileageKm: 87500,
        nextServiceMileageKm: 90000,
      );
      await repo.save(vehicle);

      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.path, '/vehicles');
      expect(adapter.requests.single.data, isNotNull);
    });
  });
}
