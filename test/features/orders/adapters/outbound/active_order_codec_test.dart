import 'package:autohub/features/orders/adapters/outbound/active_order_codec.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:flutter_test/flutter_test.dart';

const _inProgressJson = '''
[
  {
    "id": "4521",
    "title": "Заміна гальмівних колодок",
    "status": "in_progress",
    "status_label": "У ремонті",
    "vehicle": {"make": "Toyota", "model": "Camry", "plate": "AA 1234 BC"},
    "progress": 0.6,
    "eta": "2026-05-10T14:00:00+03:00",
    "total_uah": 2850,
    "timeline": [
      {"stage": "accepted", "label": "Прийнято", "at": "2026-05-10T10:24:00+03:00"},
      {"stage": "diagnostics", "label": "Діагностика", "at": "2026-05-10T11:05:00+03:00"},
      {"stage": "in_progress", "label": "У ремонті", "at": "2026-05-10T12:30:00+03:00"}
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
    "status_label": "Очікує підтвердження",
    "vehicle": {"make": "Toyota", "model": "Camry", "plate": "AA 1234 BC"},
    "scheduled_for": "2026-05-10T16:00:00+03:00"
  }
]
''';

ActiveOrder _sampleOrder() => ActiveOrder(
      id: '99',
      title: 'Заміна масла',
      status: ActiveOrderStatus.pendingConfirmation,
      statusLabel: 'Очікує підтвердження',
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
          label: 'Очікує підтвердження',
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
      expect(o.timeline[1].label, 'Діагностика');
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
            "status_label": "Скасовано",
            "vehicle": {"make": "Toyota", "model": "Camry", "plate": "AA 1234 BC"},
            "timeline": [
              {"stage": "canceled", "label": "Скасовано", "at": "2026-05-13T12:00:00Z"}
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
        statusLabel: 'Очікує підтвердження',
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
            "status_label": "z",
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
        statusLabel: 'Скасовано',
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
            label: 'Скасовано',
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
        [{"id":"x","title":"y","status":"bogus","status_label":"z",
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
      expect(r.statusLabel, original.statusLabel);
      expect(r.scheduledFor, original.scheduledFor);
      expect(r.timeline, original.timeline);
    });

    test('round-trips an in-progress order with eta + progress', () {
      final o = ActiveOrder(
        id: '1',
        title: 'X',
        status: ActiveOrderStatus.inProgress,
        statusLabel: 'У ремонті',
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
  });
}
