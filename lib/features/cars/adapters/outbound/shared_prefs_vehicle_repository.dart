import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../application/ports/outbound/vehicle_repository_port.dart';
import '../../domain/vehicle.dart';
import 'vehicle_codec.dart';

/// Seeds [seed] only when the underlying key is absent — restarts after
/// a save don't clobber user data. Seed write is fire-and-forget because
/// the constructor must stay sync.
class SharedPrefsVehicleRepository implements VehicleRepositoryPort {
  SharedPrefsVehicleRepository(this._prefs, {List<Vehicle> seed = const []}) {
    if (!_prefs.containsKey(_key) && seed.isNotEmpty) {
      unawaited(_writeAll(seed));
    }
  }

  static const _key = 'vehicles';
  final SharedPreferences _prefs;

  @override
  Future<List<Vehicle>> findAll() async => _readAll();

  @override
  Future<Vehicle?> findById(String id) async {
    for (final v in _readAll()) {
      if (v.id == id) return v;
    }
    return null;
  }

  @override
  Future<void> save(Vehicle vehicle) async {
    final current = _readAll();
    final idx = current.indexWhere((v) => v.id == vehicle.id);
    if (idx >= 0) {
      current[idx] = vehicle;
    } else {
      current.add(vehicle);
    }
    await _writeAll(current);
  }

  List<Vehicle> _readAll() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      return decodeVehicles(raw);
    } on Object catch (_) {
      return [];
    }
  }

  Future<void> _writeAll(List<Vehicle> vehicles) {
    return _prefs.setString(_key, encodeVehicles(vehicles));
  }
}
