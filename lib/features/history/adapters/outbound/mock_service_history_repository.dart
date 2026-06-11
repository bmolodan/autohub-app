import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../application/ports/outbound/service_history_repository_port.dart';
import '../../domain/service_record.dart';

/// Asset-backed adapter — reads `assets/mocks/service_history.json`.
class MockServiceHistoryRepository implements ServiceHistoryRepositoryPort {
  const MockServiceHistoryRepository();

  static const _assetPath = 'assets/mocks/service_history.json';

  @override
  Future<List<ServiceRecord>> findAll() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>().map(_recordFromJson).toList();
  }

  @override
  Future<List<ServiceRecord>> findByVehicle(String vehicleId) async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .where((m) => m['vehicle_id'] == vehicleId)
        .map(_recordFromJson)
        .toList();
  }

  ServiceRecord _recordFromJson(Map<String, dynamic> m) {
    final vehicleMap = m['vehicle'] as Map<String, dynamic>? ?? const {};
    return ServiceRecord(
      id: m['id'] as String,
      title: m['title'] as String,
      completedAt: DateTime.parse(m['completed_at'] as String),
      vehicleId: m['vehicle_id'] as String? ?? '',
      vehicle: ServiceVehicleRef(
        make: vehicleMap['make'] as String? ?? '',
        model: vehicleMap['model'] as String? ?? '',
        plate: vehicleMap['plate'] as String? ?? '',
      ),
    );
  }
}
