import 'package:autohub/features/history/adapters/outbound/http_service_history_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/fake_http_adapter.dart';

void main() {
  group('HttpServiceHistoryRepository.findByVehicle', () {
    test('GETs /history/<vehicleId> and decodes records', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(200, [
          {
            'id': 'h1',
            'title': 'ТО-15000',
            'completed_at': '2026-04-18T11:30:00Z',
            'price_uah': 2400,
            'vehicle_id': 'v-camry-1',
          },
        ]),
      );
      final repo = HttpServiceHistoryRepository(dioWith(adapter));

      final out = await repo.findByVehicle('v-camry-1');

      expect(out, hasLength(1));
      expect(out.single.title, 'ТО-15000');
      expect(out.single.priceUah, 2400);
      expect(adapter.requests.single.path, '/history/v-camry-1');
    });

    test('returns empty list when server returns []', () async {
      final adapter = FakeHttpAdapter((_) => FakeResponse.json(200, <int>[]));
      final repo = HttpServiceHistoryRepository(dioWith(adapter));

      expect(await repo.findByVehicle('v-camry-1'), isEmpty);
    });

    test('throws on 500', () async {
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 500, body: 'boom'),
      );
      final repo = HttpServiceHistoryRepository(dioWith(adapter));

      expect(repo.findByVehicle('v-camry-1'), throwsA(anything));
    });
  });
}
