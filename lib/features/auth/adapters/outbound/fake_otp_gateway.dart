import '../../../../core/util/clock.dart';
import '../../../../core/util/id_generator.dart';
import '../../application/ports/outbound/otp_gateway_port.dart';
import '../../domain/session.dart';

/// Local-only OTP gateway used until a real SMS provider is wired in.
/// Accepts the code "0000" for any phone.
class FakeOtpGateway implements OtpGatewayPort {
  FakeOtpGateway({required Clock clock, required IdGenerator idGen})
      : _clock = clock,
        _idGen = idGen;

  final Clock _clock;
  final IdGenerator _idGen;
  final Map<String, String> _phoneByChallenge = {};

  @override
  Future<OtpChallenge> request(String phone) async {
    final id = _idGen.next('ch');
    _phoneByChallenge[id] = phone;
    return OtpChallenge(id: id, phone: phone);
  }

  @override
  Future<Session> verify({
    required String challengeId,
    required String code,
  }) async {
    final phone = _phoneByChallenge[challengeId];
    if (phone == null) {
      throw const InvalidOtpException(InvalidOtpReason.expired);
    }
    if (code != '0000') {
      throw const InvalidOtpException();
    }
    final now = _clock.now();
    return Session(
      phone: phone,
      accessToken: 'fake-access',
      refreshToken: 'fake-refresh',
      accessExpiresAt: now.add(const Duration(minutes: 15)),
      createdAt: now,
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    // No-op for local env — there's no server to revoke against.
  }
}
