import 'package:autohub/features/profile/adapters/outbound/http_client_profile_repository.dart';
import 'package:autohub/features/profile/domain/client_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/fake_http_adapter.dart';

void main() {
  group('HttpClientProfileRepository.findByPhone', () {
    test('GETs /profile and decodes name + email', () async {
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(200, {
          'phone': '380661947878',
          'personId': '35414850',
          'name': 'Максим',
          'email': null,
        }),
      );
      final repo = HttpClientProfileRepository(dioWith(adapter));

      final out = await repo.findByPhone('380661947878');

      expect(out, isA<ClientProfile>());
      expect(out!.name, 'Максим');
      expect(out.email, isNull);
      expect(out.phone, '380661947878');
      expect(adapter.requests.single.path, '/profile');
    });

    test('returns null when middleware reports an empty name', () async {
      // Phone has no RoApp footprint → middleware emits name: ''
      final adapter = FakeHttpAdapter(
        (_) => FakeResponse.json(200, {
          'phone': '380501234567',
          'personId': null,
          'name': '',
          'email': null,
        }),
      );
      final repo = HttpClientProfileRepository(dioWith(adapter));

      expect(await repo.findByPhone('380501234567'), isNull);
    });

    test('throws on 5xx', () async {
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 502, body: 'upstream'),
      );
      final repo = HttpClientProfileRepository(dioWith(adapter));

      expect(repo.findByPhone('380661947878'), throwsA(anything));
    });
  });

  group('HttpClientProfileRepository write paths', () {
    test('save throws UnimplementedError (PATCH not supported yet)', () async {
      final repo = HttpClientProfileRepository(
        dioWith(FakeHttpAdapter((_) => FakeResponse.json(200, {}))),
      );
      expect(
        repo.save(const ClientProfile(phone: '380661947878', name: 'X')),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('clear throws UnimplementedError', () async {
      final repo = HttpClientProfileRepository(
        dioWith(FakeHttpAdapter((_) => FakeResponse.json(200, {}))),
      );
      expect(repo.clear(), throwsA(isA<UnimplementedError>()));
    });
  });
}
