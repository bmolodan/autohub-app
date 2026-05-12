import 'package:autohub/features/auth/adapters/outbound/fake_otp_gateway.dart';
import 'package:autohub/features/auth/application/ports/outbound/otp_gateway_port.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeOtpGateway', () {
    test('request returns a challenge tied to phone', () async {
      final gateway = FakeOtpGateway();
      final ch = await gateway.request('+380671234567');
      expect(ch.phone, '+380671234567');
      expect(ch.id, isNotEmpty);
    });

    test('verify accepts "0000" and returns session for the challenge phone',
        () async {
      final gateway = FakeOtpGateway();
      final ch = await gateway.request('+380671234567');
      final session = await gateway.verify(challengeId: ch.id, code: '0000');
      expect(session.phone, '+380671234567');
    });

    test('verify rejects any other code', () async {
      final gateway = FakeOtpGateway();
      final ch = await gateway.request('+380671234567');
      expect(
        () => gateway.verify(challengeId: ch.id, code: '1234'),
        throwsA(isA<InvalidOtpException>()),
      );
    });

    test('verify rejects unknown challenge id', () async {
      final gateway = FakeOtpGateway();
      expect(
        () => gateway.verify(challengeId: 'bogus', code: '0000'),
        throwsA(isA<InvalidOtpException>()),
      );
    });
  });
}
