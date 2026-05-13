import 'package:dio/dio.dart';

import '../../application/ports/outbound/active_order_repository_port.dart';
import '../../domain/active_order.dart';
import 'active_order_codec.dart';

class HttpActiveOrderRepository implements ActiveOrderRepositoryPort {
  HttpActiveOrderRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<ActiveOrder>> findAll() async {
    final response = await _dio.get<List<dynamic>>('/orders');
    return (response.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(activeOrderFromMap)
        .toList();
  }

  @override
  Future<ActiveOrder?> findById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/orders/$id');
      return activeOrderFromMap(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> save(ActiveOrder order) async {
    await _dio.post<void>('/orders', data: activeOrderToMap(order));
  }

  @override
  Future<void> clear() async {
    // Server-side account wipe not implemented in the current API surface.
    throw UnimplementedError('Server-side order wipe not supported yet');
  }
}
