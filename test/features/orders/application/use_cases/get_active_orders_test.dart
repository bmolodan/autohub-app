import 'package:autohub/features/orders/application/ports/outbound/active_order_repository_port.dart';
import 'package:autohub/features/orders/application/use_cases/get_active_orders.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ActiveOrderRepositoryPort {
  _FakeRepo(this._orders);
  final List<ActiveOrder> _orders;

  @override
  Future<List<ActiveOrder>> findAll() async => _orders;

  @override
  Future<ActiveOrder?> findById(String id) async =>
      _orders.where((o) => o.id == id).firstOrNull;

  @override
  Future<void> save(ActiveOrder order) async => _orders.add(order);
}

ActiveOrder _inProgress({
  String id = 'o1',
  double progress = 0.6,
}) =>
    ActiveOrder(
      id: id,
      title: 'Заміна колодок',
      status: ActiveOrderStatus.inProgress,
      statusLabel: 'У ремонті',
      vehicleMake: 'Toyota',
      vehicleModel: 'Camry',
      vehiclePlate: 'AA 1234 BC',
      progress: progress,
      eta: DateTime(2026, 5, 10, 14, 0),
      scheduledFor: null,
      totalUah: 2850,
    );

ActiveOrder _pending({String id = 'o2'}) => ActiveOrder(
      id: id,
      title: 'Діагностика двигуна',
      status: ActiveOrderStatus.pendingConfirmation,
      statusLabel: 'Очікує підтвердження',
      vehicleMake: 'Toyota',
      vehicleModel: 'Camry',
      vehiclePlate: 'AA 1234 BC',
      progress: null,
      eta: null,
      scheduledFor: DateTime(2026, 5, 10, 16, 0),
      totalUah: null,
    );

void main() {
  group('GetActiveOrdersUseCase', () {
    test('returns empty list when none', () async {
      final useCase = GetActiveOrdersUseCase(_FakeRepo(const []));
      expect(await useCase.execute(), isEmpty);
    });

    test('returns mixed in-progress + pending orders', () async {
      final useCase =
          GetActiveOrdersUseCase(_FakeRepo([_inProgress(), _pending()]));

      final out = await useCase.execute();
      expect(out, hasLength(2));
      expect(out[0].status, ActiveOrderStatus.inProgress);
      expect(out[0].progress, 0.6);
      expect(out[1].status, ActiveOrderStatus.pendingConfirmation);
      expect(out[1].scheduledFor, DateTime(2026, 5, 10, 16, 0));
    });

    test('preserves order from repository', () async {
      final useCase = GetActiveOrdersUseCase(_FakeRepo([
        _pending(id: 'b'),
        _inProgress(id: 'a'),
      ]));

      final out = await useCase.execute();
      expect(out.map((o) => o.id), ['b', 'a']);
    });
  });
}
