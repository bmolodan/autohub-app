import 'package:dio/dio.dart';

import '../../application/ports/outbound/client_profile_repository_port.dart';
import '../../domain/client_profile.dart';

/// Reads the customer profile from the middleware (`GET /v1/profile`), which
/// in turn extracts the client info from the latest RoApp order for the JWT
/// phone. PATCH is not supported server-side yet — `save` and `clear` throw,
/// which is fine because the auto-populate flow doesn't enter the register
/// form on first login.
class HttpClientProfileRepository implements ClientProfileRepositoryPort {
  HttpClientProfileRepository(this._dio);
  final Dio _dio;

  @override
  Future<ClientProfile?> findByPhone(String phone) async {
    final response = await _dio.get<Map<String, dynamic>>('/profile');
    final body = response.data;
    if (body == null) return null;
    final name = (body['name'] as String?) ?? '';
    if (name.isEmpty) return null;
    return ClientProfile(
      phone: body['phone'] as String? ?? phone,
      name: name,
      email: body['email'] as String?,
    );
  }

  @override
  Future<void> save(ClientProfile profile) async {
    throw UnimplementedError(
      'Server-side profile update not implemented yet — PATCH /v1/profile is Phase B+',
    );
  }

  @override
  Future<void> clear() async {
    // Server-side wipe not exposed; the account-deletion flow runs only
    // against the local adapter today.
    throw UnimplementedError('Server-side profile wipe not supported yet');
  }
}
