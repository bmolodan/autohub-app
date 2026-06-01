import '../ports/outbound/otp_gateway_port.dart';
import '../ports/outbound/session_storage_port.dart';

class SignOutUseCase {
  const SignOutUseCase(this._gateway, this._storage);
  final OtpGatewayPort _gateway;
  final SessionStoragePort _storage;

  Future<void> execute() async {
    final session = await _storage.read();
    if (session != null) {
      // Best-effort — if the server is unreachable or the token is already
      // gone, fall through to the local clear so the user is never stuck.
      try {
        await _gateway.logout(session.refreshToken);
      } on Object catch (_) {}
    }
    await _storage.clear();
  }
}
