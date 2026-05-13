import 'package:autohub/core/util/clock.dart';
import 'package:autohub/features/orders/application/ports/outbound/active_order_repository_port.dart';
import 'package:autohub/features/orders/application/use_cases/update_order_progress.dart';
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
}

final _fixedNow = DateTime.utc(2026, 5, 13, 12);

UpdateOrderProgressUseCase _useCase(ActiveOrderRepositoryPort repo) =>
    UpdateOrderProgressUseCase(repo, FixedClock(_fixedNow));

ActiveOrder _inProgress({double progress = 0.3}) => ActiveOrder(
      id: 'o1',
      title: 'Заміна колодок',
      status: ActiveOrderStatus.inProgress,
      vehicleMake: 'Toyota',
      vehicleModel: 'Camry',
      vehiclePlate: 'AA 1234 BC',
      progress: progress,
      eta: DateTime.utc(2026, 5, 13, 16),
      scheduledFor: null,
      totalUah: 2850,
    );

void main() {
  group('UpdateOrderProgressUseCase', () {
    test('updates progress value', () async {
      final repo = _FakeRepo();
      await repo.save(_inProgress());

      final updated = await _useCase(repo).execute(
        const UpdateOrderProgressInput(id: 'o1', progress: 0.75),
      );

      expect(updated.progress, 0.75);
      expect((await repo.findById('o1'))!.progress, 0.75);
    });

    test('appends timeline entry when newStage provided', () async {
      final repo = _FakeRepo();
      await repo.save(_inProgress());

      final updated = await _useCase(repo).execute(
        const UpdateOrderProgressInput(
          id: 'o1',
          progress: 1.0,
          newStage: OrderStage.done,
        ),
      );

      expect(updated.timeline, hasLength(1));
      expect(updated.timeline.single.stage, OrderStage.done);
      expect(updated.timeline.single.at, _fixedNow);
    });

    test('does not append timeline entry when stage omitted', () async {
      final repo = _FakeRepo();
      await repo.save(_inProgress());

      final updated = await _useCase(repo).execute(
        const UpdateOrderProgressInput(id: 'o1', progress: 0.5),
      );

      expect(updated.timeline, isEmpty);
    });

    test('throws StateError when order not found', () async {
      final repo = _FakeRepo();
      expect(
        () => _useCase(repo).execute(
          const UpdateOrderProgressInput(id: 'missing', progress: 0.5),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects update on a canceled order', () async {
      final repo = _FakeRepo();
      await repo.save(const ActiveOrder(
        id: 'o1',
        title: 'X',
        status: ActiveOrderStatus.canceled,
        vehicleMake: 'M',
        vehicleModel: 'X',
        vehiclePlate: 'P',
        progress: null,
        eta: null,
        scheduledFor: null,
        totalUah: 0,
      ));

      expect(
        () => _useCase(repo).execute(
          const UpdateOrderProgressInput(id: 'o1', progress: 0.5),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects progress < 0 or > 1', () async {
      final repo = _FakeRepo();
      await repo.save(_inProgress());

      expect(
        () => _useCase(repo).execute(
          const UpdateOrderProgressInput(id: 'o1', progress: -0.1),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => _useCase(repo).execute(
          const UpdateOrderProgressInput(id: 'o1', progress: 1.5),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
