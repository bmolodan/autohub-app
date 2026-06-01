import 'dart:convert';

import 'package:autohub/core/util/jwt_payload.dart';
import 'package:autohub/features/auth/adapters/outbound/http_otp_gateway.dart';
import 'package:autohub/features/auth/application/ports/outbound/otp_gateway_port.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/fake_http_adapter.dart';

/// Builds a syntactically-valid JWT (HS256 header + given payload + dummy sig)
/// so the gateway's exp-parser has something to chew on. Signature isn't
/// validated client-side.
String _jwt(Map<String, dynamic> payload) {
  String b64(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${b64({'alg': 'HS256', 'typ': 'JWT'})}.${b64(payload)}.signature';
}

void main() {
  group('HttpOtpGateway.request', () {
    test('POSTs phone, returns challenge using the caller\'s phone', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(200, {'challengeId': 'ch-abc'}),
      );
      final gateway = HttpOtpGateway(dioWith(adapter));

      final ch = await gateway.request('+380671234567');

      expect(ch.id, 'ch-abc');
      expect(ch.phone, '+380671234567'); // not from server — middleware doesn't return it
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.path, '/auth/otp/request');
    });
  });

  group('HttpOtpGateway.verify', () {
    test('builds Session from { accessToken, refreshToken, profile }', () async {
      final exp =
          DateTime.utc(2026, 5, 13, 12, 15).millisecondsSinceEpoch ~/ 1000;
      final accessToken = _jwt({'sub': 'acc-1', 'phone': '+380671234567', 'exp': exp});
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(200, {
          'accessToken': accessToken,
          'refreshToken': 'rt-secret-base64url',
          'profile': {'phone': '+380671234567', 'personId': null},
        }),
      );
      final gateway = HttpOtpGateway(dioWith(adapter));

      final session = await gateway.verify(challengeId: 'ch-abc', code: '0000');

      expect(session.phone, '+380671234567');
      expect(session.accessToken, accessToken);
      expect(session.refreshToken, 'rt-secret-base64url');
      expect(session.accessExpiresAt, DateTime.utc(2026, 5, 13, 12, 15));
      // createdAt is whatever DateTime.now() returned — just sanity check the type.
      expect(session.createdAt.isUtc, isTrue);
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

  group('HttpOtpGateway.logout', () {
    test('POSTs the refresh token to /auth/logout', () async {
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 204, body: ''),
      );
      final gateway = HttpOtpGateway(dioWith(adapter));

      await gateway.logout('rt-secret');

      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.path, '/auth/logout');
      expect(adapter.requests.single.data, {'refreshToken': 'rt-secret'});
    });
  });

  group('jwtExpiresAt', () {
    test('extracts exp claim as a UTC DateTime', () {
      final exp = DateTime.utc(2030, 1, 1).millisecondsSinceEpoch ~/ 1000;
      final jwt = _jwt({'sub': 'x', 'exp': exp});
      expect(jwtExpiresAt(jwt), DateTime.utc(2030, 1, 1));
    });

    test('throws on a malformed JWT', () {
      expect(() => jwtExpiresAt('not.a.jwt.with.too.many.dots'),
          throwsFormatException);
      expect(() => jwtExpiresAt('only-one-segment'), throwsFormatException);
    });

    test('throws when exp claim is missing', () {
      final jwt = _jwt({'sub': 'x'}); // no exp
      expect(() => jwtExpiresAt(jwt), throwsFormatException);
    });
  });
}
