import 'package:autohub/features/orders/application/ports/outbound/active_order_repository_port.dart';
import 'package:autohub/features/orders/application/ports/outbound/photo_storage_port.dart';
import 'package:autohub/features/orders/domain/active_order.dart';

/// Map-backed in-memory fake. `save()` replaces if id exists, appends
/// otherwise — matches `SharedPrefsActiveOrderRepository` semantics.
class FakeActiveOrderRepository implements ActiveOrderRepositoryPort {
  FakeActiveOrderRepository({List<ActiveOrder> seed = const []}) {
    for (final o in seed) {
      _store[o.id] = o;
    }
  }

  final Map<String, ActiveOrder> _store = {};

  @override
  Future<List<ActiveOrder>> findAll() async => _store.values.toList();

  @override
  Future<ActiveOrder?> findById(String id) async => _store[id];

  @override
  Future<void> save(ActiveOrder order) async {
    _store[order.id] = order;
  }
}

class FakePhotoStorage implements PhotoStoragePort {
  FakePhotoStorage({this.next});

  /// What [pickFromCamera] / [pickFromGallery] should return on the next call.
  OrderPhoto? next;
  int removeCalls = 0;

  @override
  Future<OrderPhoto?> pickFromCamera() async => next;

  @override
  Future<OrderPhoto?> pickFromGallery() async => next;

  @override
  Future<void> remove(OrderPhoto photo) async {
    removeCalls++;
  }
}
