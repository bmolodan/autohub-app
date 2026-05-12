import 'package:autohub/features/cars/domain/vehicle.dart';
import 'package:autohub/features/orders/application/ports/outbound/active_order_repository_port.dart';
import 'package:autohub/features/orders/application/use_cases/create_order.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ActiveOrderRepositoryPort {
  final Map<String, ActiveOrder> store = {};

  @override
  Future<List<ActiveOrder>> findAll() async => store.values.toList();

  @override
  Future<ActiveOrder?> findById(String id) async => store[id];

  @override
  Future<void> save(ActiveOrder order) async {
    store[order.id] = order;
  }
}

const _vehicle = Vehicle(
  id: 'v-1',
  make: 'Toyota',
  model: 'Camry',
  year: 2018,
  plate: 'AA 1234 BC',
  vin: null,
  mileageKm: 0,
  nextServiceMileageKm: null,
);

CreateOrderInput _input({
  String serviceTitle = 'Заміна масла',
  int servicePriceUah = 1600,
  String description = '',
  Vehicle vehicle = _vehicle,
}) =>
    CreateOrderInput(
      serviceTitle: serviceTitle,
      servicePriceUah: servicePriceUah,
      description: description,
      vehicle: vehicle,
    );

void main() {
  group('CreateOrderUseCase', () {
    test('saves a new pending order with a generated id', () async {
      final repo = _FakeRepo();
      final useCase = CreateOrderUseCase(repo);

      final created = await useCase.execute(_input(description: 'плановий ТО'));

      expect(created.id, isNotEmpty);
      expect(created.status, ActiveOrderStatus.pendingConfirmation);
      expect(created.statusLabel, 'Очікує підтвердження');
      expect(created.title, 'Заміна масла');
      expect(created.totalUah, 1600);
      expect(created.vehicleMake, 'Toyota');
      expect(created.vehicleModel, 'Camry');
      expect(created.vehiclePlate, 'AA 1234 BC');
      expect(created.timeline, hasLength(1));
      expect(created.timeline.single.stage, OrderStage.pendingConfirmation);

      final stored = await repo.findById(created.id);
      expect(stored, isNotNull);
      expect(stored!.id, created.id);
    });

    test('rejects empty service title', () async {
      final repo = _FakeRepo();
      expect(
        () => CreateOrderUseCase(repo).execute(_input(serviceTitle: '   ')),
        throwsA(isA<ArgumentError>()),
      );
      expect(repo.store, isEmpty);
    });

    test('rejects negative price', () async {
      final repo = _FakeRepo();
      expect(
        () => CreateOrderUseCase(repo).execute(_input(servicePriceUah: -1)),
        throwsA(isA<ArgumentError>()),
      );
      expect(repo.store, isEmpty);
    });

    test('description is optional (empty allowed)', () async {
      final repo = _FakeRepo();
      final created = await CreateOrderUseCase(repo).execute(_input());
      expect(created.id, isNotEmpty);
    });

    test('generates unique ids on successive calls', () async {
      final repo = _FakeRepo();
      final useCase = CreateOrderUseCase(repo);
      final a = await useCase.execute(_input());
      await Future<void>.delayed(const Duration(microseconds: 1));
      final b = await useCase.execute(_input(serviceTitle: 'Шиномонтаж'));
      expect(a.id, isNot(b.id));
    });
  });
}
