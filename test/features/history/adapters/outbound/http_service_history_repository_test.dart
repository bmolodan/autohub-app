import 'package:autohub/features/history/adapters/outbound/http_service_history_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/fake_http_adapter.dart';

void main() {
  const recordJson = {
    'id': 'h1',
    'title': 'ТО-15000',
    'completed_at': '2026-04-18T11:30:00Z',
    'vehicle_id': '6619680',
    'vehicle': {'make': 'Mitsubishi', 'model': 'Pajero', 'plate': 'JMB'},
  };

  group('HttpServiceHistoryRepository.findAll', () {
    test('GETs /history (no query) and decodes projected records', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(200, [recordJson]),
      );
      final repo = HttpServiceHistoryRepository(dioWith(adapter));

      final out = await repo.findAll();

      expect(out, hasLength(1));
      expect(out.single.title, 'ТО-15000');
      expect(out.single.vehicle.label, 'Mitsubishi Pajero');
      expect(adapter.requests.single.path, '/history');
    });
  });

  group('HttpServiceHistoryRepository.findByVehicle', () {
    test('GETs /history?vehicleId= and decodes records', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(200, [recordJson]),
      );
      final repo = HttpServiceHistoryRepository(dioWith(adapter));

      final out = await repo.findByVehicle('6619680');

      expect(out, hasLength(1));
      expect(out.single.vehicleId, '6619680');
      final req = adapter.requests.single;
      expect(req.path, '/history');
      expect(req.queryParameters['vehicleId'], '6619680');
    });

    test('returns empty list when server returns []', () async {
      final adapter = FakeHttpAdapter((_) => FakeResponse.json(200, <int>[]));
      final repo = HttpServiceHistoryRepository(dioWith(adapter));

      expect(await repo.findByVehicle('6619680'), isEmpty);
    });

    test('throws on 500', () async {
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 500, body: 'boom'),
      );
      final repo = HttpServiceHistoryRepository(dioWith(adapter));

      expect(repo.findByVehicle('6619680'), throwsA(anything));
    });
  });
}
