import 'package:autohub/core/util/clock.dart';
import 'package:autohub/features/orders/application/ports/outbound/active_order_repository_port.dart';
import 'package:autohub/features/orders/application/use_cases/cancel_order.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ActiveOrderRepositoryPort {
  final Map<String, ActiveOrder> store = {};

  @override
  Future<List<ActiveOrder>> findAll() async => store.values.toList();

  @override
  Future<ActiveOrder?> findById(String id) async => store[id];

  @override
  Future<void> save(ActiveOrder order) async => store[order.id] = order;

  @override
  Future<void> clear() async => store.clear();
}

final _fixedNow = DateTime.utc(2026, 5, 13, 12);

CancelOrderUseCase _useCase(ActiveOrderRepositoryPort repo) =>
    CancelOrderUseCase(repo, FixedClock(_fixedNow));

ActiveOrder _pending({String id = 'o1'}) => ActiveOrder(
      id: id,
      title: 'Заміна масла',
      status: ActiveOrderStatus.pendingConfirmation,
      vehicleMake: 'Toyota',
      vehicleModel: 'Camry',
      vehiclePlate: 'AA 1234 BC',
      progress: null,
      eta: null,
      scheduledFor: DateTime.utc(2026, 5, 14),
      totalUah: 1600,
    );

void main() {
  group('CancelOrderUseCase', () {
    test('sets status to canceled + appends canceled timeline entry', () async {
      final repo = _FakeRepo();
      await repo.save(_pending());

      final updated =
          await _useCase(repo).execute(const CancelOrderInput(id: 'o1'));

      expect(updated.status, ActiveOrderStatus.canceled);
      expect(updated.timeline, hasLength(1));
      expect(updated.timeline.single.stage, OrderStage.canceled);
      expect(updated.timeline.single.at, _fixedNow);
      expect(updated.progress, isNull);
    });

    test('persists the cancellation', () async {
      final repo = _FakeRepo();
      await repo.save(_pending());

      await _useCase(repo).execute(const CancelOrderInput(id: 'o1'));

      expect(
        (await repo.findById('o1'))!.status,
        ActiveOrderStatus.canceled,
      );
    });

    test('throws StateError when order not found', () async {
      final repo = _FakeRepo();
      expect(
        () => _useCase(repo).execute(const CancelOrderInput(id: 'missing')),
        throwsA(isA<StateError>()),
      );
    });

    test('throws StateError when order already canceled', () async {
      final repo = _FakeRepo();
      await repo.save(_pending());
      await _useCase(repo).execute(const CancelOrderInput(id: 'o1'));

      expect(
        () => _useCase(repo).execute(const CancelOrderInput(id: 'o1')),
        throwsA(isA<StateError>()),
      );
    });

    test('preserves other fields (title, vehicle, totalUah)', () async {
      final repo = _FakeRepo();
      await repo.save(_pending());

      final updated =
          await _useCase(repo).execute(const CancelOrderInput(id: 'o1'));

      expect(updated.title, 'Заміна масла');
      expect(updated.vehicleMake, 'Toyota');
      expect(updated.vehiclePlate, 'AA 1234 BC');
      expect(updated.totalUah, 1600);
      expect(updated.scheduledFor, DateTime.utc(2026, 5, 14));
    });
  });
}
