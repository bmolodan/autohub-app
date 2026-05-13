import 'package:autohub/core/util/clock.dart';
import 'package:autohub/core/util/id_generator.dart';
import 'package:autohub/features/cars/domain/vehicle.dart';
import 'package:autohub/features/orders/application/ports/outbound/active_order_repository_port.dart';
import 'package:autohub/features/orders/application/use_cases/create_order.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:flutter_test/flutter_test.dart';

CreateOrderUseCase _useCase(ActiveOrderRepositoryPort repo) =>
    CreateOrderUseCase(
      repo,
      FixedClock(DateTime.utc(2026, 5, 13, 12)),
      CountingIdGenerator(),
    );

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
  List<OrderPhoto> photos = const [],
}) =>
    CreateOrderInput(
      serviceTitle: serviceTitle,
      servicePriceUah: servicePriceUah,
      description: description,
      vehicle: vehicle,
      photos: photos,
    );

void main() {
  group('CreateOrderUseCase', () {
    test('saves a new pending order with a generated id', () async {
      final repo = _FakeRepo();
      final useCase = _useCase(repo);

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
        () => _useCase(repo).execute(_input(serviceTitle: '   ')),
        throwsA(isA<ArgumentError>()),
      );
      expect(repo.store, isEmpty);
    });

    test('rejects negative price', () async {
      final repo = _FakeRepo();
      expect(
        () => _useCase(repo).execute(_input(servicePriceUah: -1)),
        throwsA(isA<ArgumentError>()),
      );
      expect(repo.store, isEmpty);
    });

    test('description is optional (empty allowed)', () async {
      final repo = _FakeRepo();
      final created = await _useCase(repo).execute(_input());
      expect(created.id, isNotEmpty);
    });

    test('attaches photos when provided', () async {
      final repo = _FakeRepo();
      final photos = [
        OrderPhoto(
          localPath: '/tmp/a.jpg',
          takenAt: DateTime.utc(2026, 5, 13),
        ),
        OrderPhoto(
          localPath: '/tmp/b.jpg',
          takenAt: DateTime.utc(2026, 5, 13, 0, 1),
        ),
      ];

      final created = await _useCase(repo).execute(_input(photos: photos));
      expect(created.photos, photos);
      expect((await repo.findById(created.id))!.photos, photos);
    });

    test('generates unique ids on successive calls', () async {
      final repo = _FakeRepo();
      final useCase = _useCase(repo);
      final a = await useCase.execute(_input());
      final b = await useCase.execute(_input(serviceTitle: 'Шиномонтаж'));
      expect(a.id, isNot(b.id));
    });
  });
}
