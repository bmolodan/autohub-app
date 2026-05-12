import '../../domain/session.dart';
import '../ports/outbound/otp_gateway_port.dart';
import '../ports/outbound/session_storage_port.dart';

class VerifyOtpInput {
  const VerifyOtpInput({required this.challengeId, required this.code});
  final String challengeId;
  final String code;
}

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._gateway, this._storage);

  final OtpGatewayPort _gateway;
  final SessionStoragePort _storage;

  Future<Session> execute(VerifyOtpInput input) async {
    final code = input.code.trim();
    if (code.length < 4) throw ArgumentError('code must be 4 digits');

    final session = await _gateway.verify(
      challengeId: input.challengeId,
      code: code,
    );
    await _storage.write(session);
    return session;
  }
}
