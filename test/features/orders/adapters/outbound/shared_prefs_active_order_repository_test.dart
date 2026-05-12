import 'package:autohub/features/orders/adapters/outbound/shared_prefs_active_order_repository.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _seed = '''
[
  {
    "id": "seed-1",
    "title": "Заміна колодок",
    "status": "in_progress",
    "status_label": "У ремонті",
    "vehicle": {"make": "Toyota", "model": "Camry", "plate": "AA 1234 BC"},
    "progress": 0.6,
    "eta": "2026-05-10T14:00:00+03:00",
    "total_uah": 2850,
    "timeline": [
      {"stage": "accepted", "label": "Прийнято", "at": "2026-05-10T10:24:00+03:00"}
    ]
  }
]
''';

ActiveOrder _o(String id) => ActiveOrder(
      id: id,
      title: 'X',
      status: ActiveOrderStatus.pendingConfirmation,
      statusLabel: 'Pending',
      vehicleMake: 'M',
      vehicleModel: 'X',
      vehiclePlate: 'P',
      progress: null,
      eta: null,
      scheduledFor: DateTime.utc(2026, 5, 14, 10),
      totalUah: 100,
      timeline: const [],
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPrefsActiveOrderRepository', () {
    test('findAll is empty when no seed and no writes', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsActiveOrderRepository(prefs);
      expect(await repo.findAll(), isEmpty);
    });

    test('seed populates on first read when storage empty', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsActiveOrderRepository(prefs, seedJson: _seed);
      final all = await repo.findAll();
      expect(all, hasLength(1));
      expect(all.single.id, 'seed-1');
      expect(all.single.timeline, hasLength(1));
    });

    test('seed is NOT reapplied after save (simulated restart)', () async {
      final prefs = await SharedPreferences.getInstance();
      await SharedPrefsActiveOrderRepository(prefs, seedJson: _seed)
          .save(_o('added'));

      // New instance, same prefs.
      final repo2 = SharedPrefsActiveOrderRepository(prefs, seedJson: _seed);
      final all = await repo2.findAll();
      expect(all.map((o) => o.id), containsAll(['seed-1', 'added']));
      expect(all, hasLength(2));
    });

    test('findById hits saved and missing', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsActiveOrderRepository(prefs);
      await repo.save(_o('a'));

      expect((await repo.findById('a'))!.id, 'a');
      expect(await repo.findById('missing'), isNull);
    });

    test('save overwrites existing order with same id', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsActiveOrderRepository(prefs);

      await repo.save(_o('a'));
      await repo.save(const ActiveOrder(
        id: 'a',
        title: 'Updated',
        status: ActiveOrderStatus.pendingConfirmation,
        statusLabel: 'Pending',
        vehicleMake: 'M',
        vehicleModel: 'X',
        vehiclePlate: 'P',
        progress: null,
        eta: null,
        scheduledFor: null,
        totalUah: 999,
        timeline: [],
      ));

      final found = await repo.findById('a');
      expect(found!.title, 'Updated');
      expect(found.totalUah, 999);
      expect(await repo.findAll(), hasLength(1));
    });

    test('findAll returns empty for corrupt storage', () async {
      SharedPreferences.setMockInitialValues({
        'active_orders': '[not json',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsActiveOrderRepository(prefs);
      expect(await repo.findAll(), isEmpty);
    });
  });
}
