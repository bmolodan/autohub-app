import 'package:dio/dio.dart';

import '../../application/ports/outbound/service_history_repository_port.dart';
import '../../domain/service_record.dart';

class HttpServiceHistoryRepository implements ServiceHistoryRepositoryPort {
  HttpServiceHistoryRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<ServiceRecord>> findAll() async {
    final response = await _dio.get<List<dynamic>>('/history');
    return _decode(response.data);
  }

  @override
  Future<List<ServiceRecord>> findByVehicle(String vehicleId) async {
    final response = await _dio.get<List<dynamic>>(
      '/history',
      queryParameters: {'vehicleId': vehicleId},
    );
    return _decode(response.data);
  }

  List<ServiceRecord> _decode(List<dynamic>? raw) {
    final out = <ServiceRecord>[];
    for (final m in (raw ?? const []).cast<Map<String, dynamic>>()) {
      final record = _tryRecordFromMap(m);
      if (record != null) out.add(record);
    }
    return out;
  }

  /// Skip malformed records (e.g. unparseable completed_at) so a single bad
  /// row doesn't sink the whole history fetch. Middleware filters most of
  /// these at the source; this is belt-and-suspenders.
  ServiceRecord? _tryRecordFromMap(Map<String, dynamic> m) {
    try {
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
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
