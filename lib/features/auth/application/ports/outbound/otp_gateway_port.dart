import '../../../domain/session.dart';

/// Server-issued OTP challenge.
class OtpChallenge {
  const OtpChallenge({required this.id, required this.phone});
  final String id;
  final String phone;
}

enum InvalidOtpReason { wrongCode, expired }

/// Thrown when [OtpGatewayPort.verify] is called with a code the server rejects.
class InvalidOtpException implements Exception {
  const InvalidOtpException([this.reason = InvalidOtpReason.wrongCode]);
  final InvalidOtpReason reason;
  @override
  String toString() => 'InvalidOtpException($reason)';
}

/// Outbound port — speaks to whatever issues + validates OTP codes
/// (SMS provider, Firebase Auth, etc.).
abstract interface class OtpGatewayPort {
  Future<OtpChallenge> request(String phone);

  Future<Session> verify({required String challengeId, required String code});
}
