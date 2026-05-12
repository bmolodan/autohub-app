import 'package:autohub/features/auth/application/ports/outbound/otp_gateway_port.dart';
import 'package:autohub/features/auth/application/ports/outbound/session_storage_port.dart';
import 'package:autohub/features/auth/application/use_cases/request_otp.dart';
import 'package:autohub/features/auth/application/use_cases/sign_out.dart';
import 'package:autohub/features/auth/application/use_cases/verify_otp.dart';
import 'package:autohub/features/auth/domain/session.dart';
import 'package:flutter_test/flutter_test.dart';

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
    return Session(phone: phone, createdAt: DateTime(2026, 5, 12));
  }
}

class _FakeStorage implements SessionStoragePort {
  Session? _session;

  @override
  Future<Session?> read() async => _session;

  @override
  Future<void> write(Session session) async => _session = session;

  @override
  Future<void> clear() async => _session = null;
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
    test('returns session and persists it on success', () async {
      final gateway = _FakeGateway();
      final storage = _FakeStorage();
      final useCase = VerifyOtpUseCase(gateway, storage);

      final session = await useCase.execute(
        const VerifyOtpInput(challengeId: 'ch-+380671234567', code: '0000'),
      );

      expect(session.phone, '+380671234567');
      final persisted = await storage.read();
      expect(persisted, isNotNull);
      expect(persisted!.phone, '+380671234567');
    });

    test('throws InvalidOtpException on wrong code; storage stays empty',
        () async {
      final storage = _FakeStorage();
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
      final useCase = VerifyOtpUseCase(gateway, _FakeStorage());

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
      final storage = _FakeStorage();
      await storage.write(
        Session(phone: '+380671234567', createdAt: DateTime(2026, 5, 12)),
      );

      await SignOutUseCase(storage).execute();
      expect(await storage.read(), isNull);
    });
  });
}
