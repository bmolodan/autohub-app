import 'package:autohub/features/auth/adapters/outbound/http_otp_gateway.dart';
import 'package:autohub/features/auth/application/ports/outbound/otp_gateway_port.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/fake_http_adapter.dart';

void main() {
  group('HttpOtpGateway.request', () {
    test('POSTs phone to /auth/otp/request and returns challenge', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(200, {
          'challengeId': 'ch-abc',
          'phone': '+380671234567',
        }),
      );
      final gateway = HttpOtpGateway(dioWith(adapter));

      final ch = await gateway.request('+380671234567');

      expect(ch.id, 'ch-abc');
      expect(ch.phone, '+380671234567');
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.path, '/auth/otp/request');
    });
  });

  group('HttpOtpGateway.verify', () {
    test('returns session on 200', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(200, {
          'phone': '+380671234567',
          'createdAt': '2026-05-13T12:00:00Z',
        }),
      );
      final gateway = HttpOtpGateway(dioWith(adapter));

      final session = await gateway.verify(challengeId: 'ch-abc', code: '0000');

      expect(session.phone, '+380671234567');
      expect(session.createdAt, DateTime.utc(2026, 5, 13, 12));
    });

    test('throws InvalidOtpException on 401', () async {
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 401, body: ''),
      );
      final gateway = HttpOtpGateway(dioWith(adapter));

      await expectLater(
        () => gateway.verify(challengeId: 'ch-abc', code: '1234'),
        throwsA(isA<InvalidOtpException>()),
      );
    });
  });
}
