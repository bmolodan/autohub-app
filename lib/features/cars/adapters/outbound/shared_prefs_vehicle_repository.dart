import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../application/ports/outbound/vehicle_repository_port.dart';
import '../../domain/vehicle.dart';

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
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .cast<Map<String, dynamic>>()
          .map(_vehicleFromJson)
          .toList();
    } on Object catch (_) {
      return [];
    }
  }

  Future<void> _writeAll(List<Vehicle> vehicles) {
    final encoded = jsonEncode(vehicles.map(_vehicleToJson).toList());
    return _prefs.setString(_key, encoded);
  }

  Map<String, dynamic> _vehicleToJson(Vehicle v) => {
        'id': v.id,
        'make': v.make,
        'model': v.model,
        'year': v.year,
        'plate': v.plate,
        'vin': v.vin,
        'mileageKm': v.mileageKm,
        'nextServiceMileageKm': v.nextServiceMileageKm,
      };

  Vehicle _vehicleFromJson(Map<String, dynamic> m) => Vehicle(
        id: m['id'] as String,
        make: m['make'] as String,
        model: m['model'] as String,
        year: (m['year'] as num).toInt(),
        plate: m['plate'] as String,
        vin: m['vin'] as String?,
        mileageKm: (m['mileageKm'] as num).toInt(),
        nextServiceMileageKm: (m['nextServiceMileageKm'] as num?)?.toInt(),
      );
}
