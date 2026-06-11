import 'dart:convert';

import '../../domain/vehicle.dart';

/// JSON ↔ Vehicle. Mirrors active_order_codec.dart so HTTP adapters can reuse it.

List<Vehicle> decodeVehicles(String json) {
  final decoded = jsonDecode(json) as List<dynamic>;
  return decoded.cast<Map<String, dynamic>>().map(_vehicleFromJson).toList();
}

String encodeVehicles(List<Vehicle> vehicles) {
  return jsonEncode(vehicles.map(_vehicleToJson).toList());
}

/// Map form for HTTP adapters that need to encode/decode a single vehicle.
Map<String, dynamic> vehicleToMap(Vehicle v) => _vehicleToJson(v);

Vehicle vehicleFromMap(Map<String, dynamic> m) => _vehicleFromJson(m);

Map<String, dynamic> _vehicleToJson(Vehicle v) => {
      'id': v.id,
      'make': v.make,
      'model': v.model,
      'modification': v.modification,
      'color': v.color,
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
      modification: m['modification'] as String? ?? '',
      color: m['color'] as String? ?? '',
      year: (m['year'] as num).toInt(),
      plate: m['plate'] as String,
      vin: m['vin'] as String?,
      mileageKm: (m['mileageKm'] as num).toInt(),
      nextServiceMileageKm: (m['nextServiceMileageKm'] as num?)?.toInt(),
    );
