import 'package:dio/dio.dart';

import '../../application/ports/outbound/service_history_repository_port.dart';
import '../../domain/service_record.dart';

class HttpServiceHistoryRepository implements ServiceHistoryRepositoryPort {
  HttpServiceHistoryRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<ServiceRecord>> findByVehicle(String vehicleId) async {
    final response = await _dio.get<List<dynamic>>('/history/$vehicleId');
    return (response.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(_recordFromMap)
        .toList();
  }

  ServiceRecord _recordFromMap(Map<String, dynamic> m) => ServiceRecord(
        id: m['id'] as String,
        title: m['title'] as String,
        completedAt: DateTime.parse(m['completed_at'] as String),
        priceUah: (m['price_uah'] as num).toInt(),
        vehicleId: m['vehicle_id'] as String,
      );
}
