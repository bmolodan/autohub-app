import 'package:dio/dio.dart';

import '../../application/ports/outbound/otp_gateway_port.dart';
import '../../domain/session.dart';

class HttpOtpGateway implements OtpGatewayPort {
  HttpOtpGateway(this._dio);
  final Dio _dio;

  @override
  Future<OtpChallenge> request(String phone) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/request',
      data: {'phone': phone},
    );
    final m = response.data;
    if (m == null) {
      throw const FormatException('OTP request returned empty body');
    }
    return OtpChallenge(
      id: m['challengeId'] as String,
      phone: m['phone'] as String,
    );
  }

  @override
  Future<Session> verify({
    required String challengeId,
    required String code,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/otp/verify',
        data: {'challengeId': challengeId, 'code': code},
      );
      final m = response.data;
      if (m == null) throw const InvalidOtpException();
      return Session(
        phone: m['phone'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const InvalidOtpException();
      }
      rethrow;
    }
  }
}
