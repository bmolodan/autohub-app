import 'package:autohub/features/orders/application/ports/outbound/active_order_repository_port.dart';
import 'package:autohub/features/orders/application/use_cases/get_order_by_id.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ActiveOrderRepositoryPort {
  final Map<String, ActiveOrder> _store;
  _FakeRepo(List<ActiveOrder> seed) : _store = {for (final o in seed) o.id: o};

  @override
  Future<List<ActiveOrder>> findAll() async => _store.values.toList();

  @override
  Future<ActiveOrder?> findById(String id) async => _store[id];

  @override
  Future<void> save(ActiveOrder order) async {
    _store[order.id] = order;
  }

  @override
  Future<void> clear() async => _store.clear();
}

ActiveOrder _o(String id) => ActiveOrder(
      id: id,
      title: 't',
      status: ActiveOrderStatus.pendingConfirmation,
      vehicleMake: 'M',
      vehicleModel: 'X',
      vehiclePlate: 'P',
      progress: null,
      eta: null,
      scheduledFor: null,
      totalUah: null,
    );

void main() {
  group('GetOrderByIdUseCase', () {
    test('returns the order when present', () async {
      final repo = _FakeRepo([_o('a'), _o('b')]);
      final out = await GetOrderByIdUseCase(repo)
          .execute(const GetOrderByIdInput(id: 'a'));
      expect(out, isNotNull);
      expect(out!.id, 'a');
    });

    test('returns null when missing', () async {
      final repo = _FakeRepo([]);
      final out = await GetOrderByIdUseCase(repo)
          .execute(const GetOrderByIdInput(id: 'x'));
      expect(out, isNull);
    });
  });
}
