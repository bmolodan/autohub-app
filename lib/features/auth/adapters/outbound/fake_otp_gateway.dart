import '../../application/ports/outbound/otp_gateway_port.dart';
import '../../domain/session.dart';

/// Local-only OTP gateway used until a real SMS provider is wired in.
/// Accepts the code "0000" for any phone.
class FakeOtpGateway implements OtpGatewayPort {
  final Map<String, String> _challengesByPhone = {};
  final Map<String, String> _phoneByChallenge = {};

  @override
  Future<OtpChallenge> request(String phone) async {
    final id = 'ch-${DateTime.now().microsecondsSinceEpoch}';
    _challengesByPhone[phone] = id;
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
      throw const InvalidOtpException('Час дії коду минув');
    }
    if (code != '0000') {
      throw const InvalidOtpException();
    }
    return Session(phone: phone, createdAt: DateTime.now());
  }
}
