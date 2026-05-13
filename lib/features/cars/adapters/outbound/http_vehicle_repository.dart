import 'package:dio/dio.dart';

import '../../application/ports/outbound/vehicle_repository_port.dart';
import '../../domain/vehicle.dart';
import 'vehicle_codec.dart';

class HttpVehicleRepository implements VehicleRepositoryPort {
  HttpVehicleRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Vehicle>> findAll() async {
    final response = await _dio.get<List<dynamic>>('/vehicles');
    return (response.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(vehicleFromMap)
        .toList();
  }

  @override
  Future<Vehicle?> findById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/vehicles/$id');
      return vehicleFromMap(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> save(Vehicle vehicle) async {
    await _dio.post<void>('/vehicles', data: vehicleToMap(vehicle));
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dio.delete<void>('/vehicles/$id');
    } on DioException catch (e) {
      // 404 means already gone — treat as success.
      if (e.response?.statusCode == 404) return;
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    // Server-side account wipe is a backend-of-the-future concern; not
    // exposed by the current API surface. The account-deletion flow only
    // runs against the local adapter today.
    throw UnimplementedError('Server-side vehicle wipe not supported yet');
  }
}
