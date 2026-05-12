import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../application/ports/outbound/service_history_repository_port.dart';
import '../../domain/service_record.dart';

/// Asset-backed adapter — reads `assets/mocks/service_history.json`.
///
/// Replace with an HTTP-backed adapter when the real API is wired in.
/// Use-case code never changes because both implement the same port.
class MockServiceHistoryRepository implements ServiceHistoryRepositoryPort {
  const MockServiceHistoryRepository();

  static const _assetPath = 'assets/mocks/service_history.json';

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

  ServiceRecord _recordFromJson(Map<String, dynamic> m) => ServiceRecord(
        id: m['id'] as String,
        title: m['title'] as String,
        completedAt: DateTime.parse(m['completed_at'] as String),
        priceUah: (m['price_uah'] as num).toInt(),
        vehicleId: m['vehicle_id'] as String,
      );
}
