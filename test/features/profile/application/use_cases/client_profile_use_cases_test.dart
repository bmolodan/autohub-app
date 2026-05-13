import 'package:autohub/features/profile/application/ports/outbound/client_profile_repository_port.dart';
import 'package:autohub/features/profile/application/use_cases/get_client_profile.dart';
import 'package:autohub/features/profile/application/use_cases/save_client_profile.dart';
import 'package:autohub/features/profile/domain/client_profile.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ClientProfileRepositoryPort {
  ClientProfile? _stored;

  @override
  Future<ClientProfile?> findByPhone(String phone) async =>
      _stored?.phone == phone ? _stored : null;

  @override
  Future<void> save(ClientProfile profile) async {
    _stored = profile;
  }

  @override
  Future<void> clear() async {
    _stored = null;
  }
}

void main() {
  group('GetClientProfileUseCase', () {
    test('returns null when no profile is saved', () async {
      final repo = _FakeRepo();
      final result =
          await GetClientProfileUseCase(repo).execute('+380671234567');
      expect(result, isNull);
    });

    test('returns the stored profile for the matching phone', () async {
      final repo = _FakeRepo();
      await repo.save(const ClientProfile(
        phone: '+380671234567',
        name: 'Bohdan',
        email: 'bohdan@example.com',
      ));
      final result =
          await GetClientProfileUseCase(repo).execute('+380671234567');
      expect(result?.name, 'Bohdan');
      expect(result?.email, 'bohdan@example.com');
    });

    test('returns null when phone does not match the stored profile', () async {
      final repo = _FakeRepo();
      await repo.save(const ClientProfile(
        phone: '+380671234567',
        name: 'Bohdan',
      ));
      final result = await GetClientProfileUseCase(repo).execute('+1234');
      expect(result, isNull);
    });
  });

  group('SaveClientProfileUseCase', () {
    test('persists name + email and trims', () async {
      final repo = _FakeRepo();
      final saved = await SaveClientProfileUseCase(repo).execute(
        const SaveClientProfileInput(
          phone: '+380671234567',
          name: '  Bohdan  ',
          email: '  bohdan@example.com  ',
        ),
      );
      expect(saved.name, 'Bohdan');
      expect(saved.email, 'bohdan@example.com');
      expect(await repo.findByPhone('+380671234567'), isNotNull);
    });

    test('treats empty / whitespace email as absent', () async {
      final repo = _FakeRepo();
      final saved = await SaveClientProfileUseCase(repo).execute(
        const SaveClientProfileInput(
          phone: '+380671234567',
          name: 'Bohdan',
          email: '   ',
        ),
      );
      expect(saved.email, isNull);
    });

    test('throws when name is empty', () async {
      final repo = _FakeRepo();
      expect(
        () => SaveClientProfileUseCase(repo).execute(
          const SaveClientProfileInput(
            phone: '+380671234567',
            name: '   ',
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when phone is empty', () async {
      final repo = _FakeRepo();
      expect(
        () => SaveClientProfileUseCase(repo).execute(
          const SaveClientProfileInput(phone: '   ', name: 'Bohdan'),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
