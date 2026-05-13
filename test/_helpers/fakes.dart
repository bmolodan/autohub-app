import 'package:autohub/features/auth/application/ports/outbound/session_storage_port.dart';
import 'package:autohub/features/auth/domain/session.dart';
import 'package:autohub/features/cars/application/ports/outbound/car_catalog_port.dart';
import 'package:autohub/features/cars/application/ports/outbound/vehicle_repository_port.dart';
import 'package:autohub/features/cars/data/car_catalog.dart';
import 'package:autohub/features/cars/domain/vehicle.dart';
import 'package:autohub/features/orders/application/ports/outbound/active_order_repository_port.dart';
import 'package:autohub/features/orders/application/ports/outbound/photo_storage_port.dart';
import 'package:autohub/features/orders/domain/active_order.dart';
import 'package:autohub/features/profile/application/ports/outbound/client_profile_repository_port.dart';
import 'package:autohub/features/profile/domain/client_profile.dart';

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

  @override
  Future<void> clear() async {
    _store.clear();
  }
}

class FakeVehicleRepository implements VehicleRepositoryPort {
  FakeVehicleRepository({List<Vehicle> seed = const []}) : _items = [...seed];

  final List<Vehicle> _items;

  @override
  Future<List<Vehicle>> findAll() async => List.unmodifiable(_items);

  @override
  Future<Vehicle?> findById(String id) async {
    for (final v in _items) {
      if (v.id == id) return v;
    }
    return null;
  }

  @override
  Future<void> save(Vehicle vehicle) async {
    final i = _items.indexWhere((v) => v.id == vehicle.id);
    if (i >= 0) {
      _items[i] = vehicle;
    } else {
      _items.add(vehicle);
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((v) => v.id == id);
  }

  @override
  Future<void> clear() async {
    _items.clear();
  }
}

class FakeCarCatalogPort implements CarCatalogPort {
  FakeCarCatalogPort(this._catalog);

  final CarCatalog _catalog;

  @override
  Future<CarCatalog> load() async => _catalog;
}

class FakeClientProfileRepository implements ClientProfileRepositoryPort {
  FakeClientProfileRepository({ClientProfile? seed}) : _stored = seed;

  ClientProfile? _stored;

  @override
  Future<ClientProfile?> findByPhone(String phone) async =>
      _stored?.phone == phone ? _stored : null;

  @override
  Future<void> save(ClientProfile profile) async {
    _stored = profile;
  }

  @override
  Future<void> clear() async {
    _stored = null;
  }
}

class FakeSessionStorage implements SessionStoragePort {
  FakeSessionStorage({Session? seed}) : _stored = seed;

  Session? _stored;

  @override
  Future<Session?> read() async => _stored;

  @override
  Future<void> write(Session session) async {
    _stored = session;
  }

  @override
  Future<void> clear() async {
    _stored = null;
  }
}

class FakePhotoStorage implements PhotoStoragePort {
  FakePhotoStorage({this.next, this.multi = const []});

  /// What [pickFromCamera] / [pickFromGallery] should return on the next call.
  OrderPhoto? next;

  /// What [pickMultipleFromGallery] should return on the next call.
  List<OrderPhoto> multi;
  int removeCalls = 0;

  @override
  Future<OrderPhoto?> pickFromCamera() async => next;

  @override
  Future<OrderPhoto?> pickFromGallery() async => next;

  @override
  Future<List<OrderPhoto>> pickMultipleFromGallery({required int limit}) async {
    if (limit <= 0) return const [];
    return multi.length > limit ? multi.take(limit).toList() : multi;
  }

  @override
  Future<void> remove(OrderPhoto photo) async {
    removeCalls++;
  }
}
