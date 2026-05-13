import 'package:autohub/features/orders/adapters/outbound/http_active_order_repository.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/fake_http_adapter.dart';

const _pendingJson = {
  'id': '4522',
  'title': 'Діагностика двигуна',
  'status': 'pending_confirmation',
  'vehicle': {'make': 'Toyota', 'model': 'Camry', 'plate': 'AA 1234 BC'},
  'scheduled_for': '2026-05-14T16:00:00Z',
};

void main() {
  group('HttpActiveOrderRepository', () {
    test('findAll GETs /orders and decodes the list', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(200, [_pendingJson]),
      );
      final repo = HttpActiveOrderRepository(dioWith(adapter));

      final out = await repo.findAll();

      expect(out, hasLength(1));
      expect(out.single.id, '4522');
      expect(out.single.status, ActiveOrderStatus.pendingConfirmation);
      expect(adapter.requests.single.method, 'GET');
      expect(adapter.requests.single.path, '/orders');
    });

    test('findById GETs /orders/<id> and decodes', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(200, _pendingJson),
      );
      final repo = HttpActiveOrderRepository(dioWith(adapter));

      final out = await repo.findById('4522');
      expect(out, isNotNull);
      expect(out!.title, 'Діагностика двигуна');
      expect(adapter.requests.single.path, '/orders/4522');
    });

    test('findById returns null on 404', () async {
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 404, body: ''),
      );
      final repo = HttpActiveOrderRepository(dioWith(adapter));

      expect(await repo.findById('missing'), isNull);
    });

    test('save POSTs JSON-encoded order to /orders', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(201, _pendingJson),
      );
      final repo = HttpActiveOrderRepository(dioWith(adapter));

      await repo.save(ActiveOrder(
        id: '4522',
        title: 'Діагностика двигуна',
        status: ActiveOrderStatus.pendingConfirmation,
        vehicleMake: 'Toyota',
        vehicleModel: 'Camry',
        vehiclePlate: 'AA 1234 BC',
        progress: null,
        eta: null,
        scheduledFor: DateTime.utc(2026, 5, 14, 16),
        totalUah: null,
      ));

      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.path, '/orders');
      expect(adapter.requests.single.data, isA<Map<String, dynamic>>());
    });

    test('findAll throws on 500', () async {
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 500, body: 'boom'),
      );
      final repo = HttpActiveOrderRepository(dioWith(adapter));

      expect(repo.findAll(), throwsA(anything));
    });
  });
}
