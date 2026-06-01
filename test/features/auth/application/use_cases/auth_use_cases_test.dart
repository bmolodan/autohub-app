import 'package:autohub/features/auth/application/ports/outbound/otp_gateway_port.dart';
import 'package:autohub/features/auth/application/use_cases/request_otp.dart';
import 'package:autohub/features/auth/application/use_cases/sign_out.dart';
import 'package:autohub/features/auth/application/use_cases/verify_otp.dart';
import 'package:autohub/features/auth/domain/session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/in_memory_session_storage.dart';

class _FakeGateway implements OtpGatewayPort {
  String? requestedPhone;
  String? lastChallenge;

  @override
  Future<OtpChallenge> request(String phone) async {
    requestedPhone = phone;
    lastChallenge = 'ch-$phone';
    return OtpChallenge(id: lastChallenge!, phone: phone);
  }

  @override
  Future<Session> verify({
    required String challengeId,
    required String code,
  }) async {
    if (code != '0000') throw const InvalidOtpException();
    final phone = challengeId.replaceFirst('ch-', '');
    return testSession(phone: phone);
  }
}

void main() {
  group('RequestOtpUseCase', () {
    test('forwards phone to gateway and returns challenge', () async {
      final gateway = _FakeGateway();
      final useCase = RequestOtpUseCase(gateway);

      final challenge = await useCase.execute(
        const RequestOtpInput(phone: '+380671234567'),
      );

      expect(gateway.requestedPhone, '+380671234567');
      expect(challenge.id, 'ch-+380671234567');
      expect(challenge.phone, '+380671234567');
    });

    test('rejects empty phone', () async {
      final gateway = _FakeGateway();
      final useCase = RequestOtpUseCase(gateway);
      expect(
        () => useCase.execute(const RequestOtpInput(phone: '   ')),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('VerifyOtpUseCase', () {
    test('returns session and persists all fields on success', () async {
      final gateway = _FakeGateway();
      final storage = InMemorySessionStorage();
      final useCase = VerifyOtpUseCase(gateway, storage);

      final session = await useCase.execute(
        const VerifyOtpInput(challengeId: 'ch-+380671234567', code: '0000'),
      );

      expect(session.phone, '+380671234567');
      expect(session.accessToken, isNotEmpty);
      expect(session.refreshToken, isNotEmpty);

      final persisted = await storage.read();
      expect(persisted, isNotNull);
      expect(persisted!.phone, '+380671234567');
      expect(persisted.accessToken, session.accessToken);
      expect(persisted.refreshToken, session.refreshToken);
      expect(persisted.accessExpiresAt, session.accessExpiresAt);
    });

    test('throws InvalidOtpException on wrong code; storage stays empty',
        () async {
      final storage = InMemorySessionStorage();
      final useCase = VerifyOtpUseCase(_FakeGateway(), storage);

      expect(
        () => useCase.execute(
          const VerifyOtpInput(challengeId: 'ch-x', code: '9999'),
        ),
        throwsA(isA<InvalidOtpException>()),
      );
      expect(await storage.read(), isNull);
    });

    test('rejects short code without calling gateway', () async {
      final gateway = _FakeGateway();
      final useCase = VerifyOtpUseCase(gateway, InMemorySessionStorage());

      expect(
        () => useCase.execute(
          const VerifyOtpInput(challengeId: 'ch-x', code: '12'),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(gateway.requestedPhone, isNull);
    });
  });

  group('SignOutUseCase', () {
    test('clears session in storage', () async {
      final storage = InMemorySessionStorage(testSession());

      await SignOutUseCase(storage).execute();
      expect(await storage.read(), isNull);
    });
  });
}
