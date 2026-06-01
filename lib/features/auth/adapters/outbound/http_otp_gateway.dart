import 'package:dio/dio.dart';

import '../../../../core/util/jwt_payload.dart';
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
    // Middleware response is { challengeId } — phone is the caller's input.
    return OtpChallenge(id: m['challengeId'] as String, phone: phone);
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

      final accessToken = m['accessToken'] as String;
      final refreshToken = m['refreshToken'] as String;
      final profile = m['profile'] as Map<String, dynamic>;
      return Session(
        phone: profile['phone'] as String,
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessExpiresAt: jwtExpiresAt(accessToken),
        createdAt: DateTime.now().toUtc(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const InvalidOtpException();
      }
      rethrow;
    }
  }
}

