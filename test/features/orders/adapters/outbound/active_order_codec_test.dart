import 'package:autohub/features/orders/adapters/outbound/active_order_codec.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:flutter_test/flutter_test.dart';

const _inProgressJson = '''
[
  {
    "id": "4521",
    "title": "Заміна гальмівних колодок",
    "status": "in_progress",
    "vehicle": {"make": "Toyota", "model": "Camry", "plate": "AA 1234 BC"},
    "progress": 0.6,
    "eta": "2026-05-10T14:00:00+03:00",
    "total_uah": 2850,
    "timeline": [
      {"stage": "accepted", "at": "2026-05-10T10:24:00+03:00"},
      {"stage": "diagnostics", "at": "2026-05-10T11:05:00+03:00"},
      {"stage": "in_progress", "at": "2026-05-10T12:30:00+03:00"}
    ]
  }
]
''';

const _pendingJson = '''
[
  {
    "id": "4522",
    "title": "Діагностика двигуна",
    "status": "pending_confirmation",
    "vehicle": {"make": "Toyota", "model": "Camry", "plate": "AA 1234 BC"},
    "scheduled_for": "2026-05-10T16:00:00+03:00"
  }
]
''';

ActiveOrder _sampleOrder() => ActiveOrder(
      id: '99',
      title: 'Заміна масла',
      status: ActiveOrderStatus.pendingConfirmation,
      vehicleMake: 'Toyota',
      vehicleModel: 'Camry',
      vehiclePlate: 'AA 1234 BC',
      progress: null,
      eta: null,
      scheduledFor: DateTime.utc(2026, 5, 14, 10, 0),
      totalUah: null,
      timeline: [
        OrderTimelineEntry(
          stage: OrderStage.pendingConfirmation,
          at: DateTime.utc(2026, 5, 13, 9, 0),
        ),
      ],
    );

void main() {
  group('decodeActiveOrders', () {
    test('parses in_progress order including timeline', () {
      final orders = decodeActiveOrders(_inProgressJson);

      expect(orders, hasLength(1));
      final o = orders.first;
      expect(o.status, ActiveOrderStatus.inProgress);
      expect(o.progress, 0.6);
      expect(o.totalUah, 2850);
      expect(o.timeline, hasLength(3));
      expect(o.timeline[0].stage, OrderStage.accepted);
      expect(o.timeline[1].stage, OrderStage.diagnostics);
      expect(o.timeline[2].at, DateTime.parse('2026-05-10T12:30:00+03:00'));
    });

    test('parses pending_confirmation order without timeline', () {
      final orders = decodeActiveOrders(_pendingJson);

      final o = orders.single;
      expect(o.status, ActiveOrderStatus.pendingConfirmation);
      expect(o.scheduledFor, DateTime.parse('2026-05-10T16:00:00+03:00'));
      expect(o.timeline, isEmpty);
    });

    test('returns empty list for empty array', () {
      expect(decodeActiveOrders('[]'), isEmpty);
    });

    test('parses canceled order with canceled-stage timeline entry', () {
      const json = '''
        [
          {
            "id": "x1",
            "title": "Заміна масла",
            "status": "canceled",
            "vehicle": {"make": "Toyota", "model": "Camry", "plate": "AA 1234 BC"},
            "timeline": [
              {"stage": "canceled", "at": "2026-05-13T12:00:00Z"}
            ]
          }
        ]
      ''';
      final o = decodeActiveOrders(json).single;
      expect(o.status, ActiveOrderStatus.canceled);
      expect(o.timeline.single.stage, OrderStage.canceled);
    });

    test('round-trips an order with photos', () {
      final o = ActiveOrder(
        id: 'p1',
        title: 'Заміна масла',
        status: ActiveOrderStatus.pendingConfirmation,
        vehicleMake: 'Toyota',
        vehicleModel: 'Camry',
        vehiclePlate: 'AA 1234 BC',
        progress: null,
        eta: null,
        scheduledFor: null,
        totalUah: 1600,
        photos: [
          OrderPhoto(
            localPath: '/tmp/a.jpg',
            takenAt: DateTime.utc(2026, 5, 13, 10),
          ),
          OrderPhoto(
            localPath: '/tmp/b.jpg',
            takenAt: DateTime.utc(2026, 5, 13, 10, 1),
          ),
        ],
      );
      final round = decodeActiveOrders(encodeActiveOrders([o])).single;
      expect(round.photos, o.photos);
    });

    test('defaults photos to empty when field is absent in JSON', () {
      const json = '''
        [
          {
            "id": "x",
            "title": "y",
            "status": "pending_confirmation",
            "vehicle": {"make": "a", "model": "b", "plate": "c"}
          }
        ]
      ''';
      expect(decodeActiveOrders(json).single.photos, isEmpty);
    });

    test('round-trips a canceled order', () {
      final o = ActiveOrder(
        id: 'x1',
        title: 'Заміна масла',
        status: ActiveOrderStatus.canceled,
        vehicleMake: 'Toyota',
        vehicleModel: 'Camry',
        vehiclePlate: 'AA 1234 BC',
        progress: null,
        eta: null,
        scheduledFor: null,
        totalUah: 1600,
        timeline: [
          OrderTimelineEntry(
            stage: OrderStage.canceled,
            at: DateTime.utc(2026, 5, 13, 12),
          ),
        ],
      );
      final round = decodeActiveOrders(encodeActiveOrders([o])).single;
      expect(round, o);
      expect(round.status, ActiveOrderStatus.canceled);
      expect(round.timeline.single.stage, OrderStage.canceled);
    });

    test('throws on unknown status', () {
      const bad = '''
        [{"id":"x","title":"y","status":"bogus",
          "vehicle":{"make":"a","model":"b","plate":"c"}}]
      ''';
      expect(() => decodeActiveOrders(bad), throwsA(isA<FormatException>()));
    });
  });

  group('encode/decode round-trip', () {
    test('preserves all fields including timeline and timestamps', () {
      final original = _sampleOrder();
      final encoded = encodeActiveOrders([original]);
      final decoded = decodeActiveOrders(encoded);

      expect(decoded, hasLength(1));
      final r = decoded.first;
      expect(r.id, original.id);
      expect(r.title, original.title);
      expect(r.status, original.status);
      expect(r.scheduledFor, original.scheduledFor);
      expect(r.timeline, original.timeline);
    });

    test('round-trips an in-progress order with eta + progress', () {
      final o = ActiveOrder(
        id: '1',
        title: 'X',
        status: ActiveOrderStatus.inProgress,
        vehicleMake: 'A',
        vehicleModel: 'B',
        vehiclePlate: 'C',
        progress: 0.42,
        eta: DateTime.utc(2026, 5, 14, 12, 30),
        scheduledFor: null,
        totalUah: 1234,
        timeline: const [],
      );

      final round = decodeActiveOrders(encodeActiveOrders([o])).single;
      expect(round.progress, 0.42);
      expect(round.eta, DateTime.utc(2026, 5, 14, 12, 30));
      expect(round.totalUah, 1234);
    });

    test('round-trips pricing + metadata + items', () {
      final o = ActiveOrder(
        id: '60802439',
        title: 'комп вакуумний',
        status: ActiveOrderStatus.inProgress,
        vehicleMake: 'Mitsubishi',
        vehicleModel: 'Pajero',
        vehiclePlate: 'JMBLYV98W8J403478',
        progress: null,
        eta: null,
        scheduledFor: DateTime.utc(2026, 6, 10, 8, 30),
        totalUah: 9940,
        paidUah: 0,
        discountUah: 160,
        number: 'A1966',
        orderType: 'Платний',
        resource: 'Підйомник 1',
        statusColor: '#099B49',
        createdAt: DateTime.utc(2026, 6, 1, 12, 14, 37),
        dueDate: DateTime.utc(2026, 6, 5, 12, 13),
        isUrgent: false,
        isOverdue: true,
        items: const [
          OrderItem(
            id: '1',
            name: 'Заміна',
            quantity: 1,
            priceUah: 800,
            discountUah: 160,
            sumUah: 640,
            kind: OrderItemKind.service,
          ),
          OrderItem(
            id: '2',
            name: 'Очисник',
            quantity: 2,
            priceUah: 250,
            discountUah: 0,
            sumUah: 500,
            kind: OrderItemKind.product,
          ),
        ],
      );
      final round = decodeActiveOrders(encodeActiveOrders([o])).single;
      expect(round, o);
      expect(round.statusColor, '#099B49');
      expect(round.isOverdue, true);
      expect(round.items.length, 2);
      expect(round.items[0].kind, OrderItemKind.service);
      expect(round.items[1].kind, OrderItemKind.product);
      expect(round.items[0].sumUah, 640);
    });

    test('decodes items absent → empty list; unknown kind → service', () {
      const json = '''
        [
          {
            "id":"x","title":"y","status":"in_progress",
            "vehicle":{"make":"a","model":"b","plate":"c"}
          }
        ]
      ''';
      expect(decodeActiveOrders(json).single.items, isEmpty);

      const jsonUnknownKind = '''
        [
          {
            "id":"x","title":"y","status":"in_progress",
            "vehicle":{"make":"a","model":"b","plate":"c"},
            "items":[
              {"id":"1","name":"n","quantity":1,"price_uah":10,"sum_uah":10,"kind":"weird"}
            ]
          }
        ]
      ''';
      final item = decodeActiveOrders(jsonUnknownKind).single.items.single;
      expect(item.kind, OrderItemKind.service);
      expect(item.discountUah, 0);
    });
  });
}
