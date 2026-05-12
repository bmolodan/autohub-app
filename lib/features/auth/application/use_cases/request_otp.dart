import '../ports/outbound/otp_gateway_port.dart';

class RequestOtpInput {
  const RequestOtpInput({required this.phone});
  final String phone;
}

class RequestOtpUseCase {
  const RequestOtpUseCase(this._gateway);

  final OtpGatewayPort _gateway;

  Future<OtpChallenge> execute(RequestOtpInput input) {
    final phone = input.phone.trim();
    if (phone.isEmpty) throw ArgumentError('phone is required');
    return _gateway.request(phone);
  }
}
