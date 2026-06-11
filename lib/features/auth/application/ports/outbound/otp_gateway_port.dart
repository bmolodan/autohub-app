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

enum OtpRequestFailure {
  /// Server-side per-phone cooldown (429 otp_cooldown).
  cooldown,

  /// Server-side per-phone daily cap (429 otp_daily_cap_reached).
  dailyCap,

  /// Phone failed validation (400 invalid_phone).
  invalidPhone,

  /// SMS provider rejected (502 sms_send_failed) — usually balance, blocked
  /// sender name, or transport error on the upstream side.
  smsFailed,

  /// Network/connection problem reaching the middleware.
  network,
}

/// Thrown when [OtpGatewayPort.request] cannot deliver a challenge.
class OtpRequestException implements Exception {
  const OtpRequestException(this.reason, {this.retryAfterSec});
  final OtpRequestFailure reason;

  /// Populated for [OtpRequestFailure.cooldown] and [OtpRequestFailure.dailyCap].
  final int? retryAfterSec;

  @override
  String toString() => 'OtpRequestException($reason, retryAfter=$retryAfterSec)';
}

/// Outbound port — speaks to whatever issues + validates OTP codes
/// (SMS provider, Firebase Auth, etc.).
abstract interface class OtpGatewayPort {
  Future<OtpChallenge> request(String phone);

  Future<Session> verify({required String challengeId, required String code});

  /// Best-effort server-side logout. Implementations should not throw on
  /// network errors — the caller will clear local storage regardless.
  Future<void> logout(String refreshToken);
}
