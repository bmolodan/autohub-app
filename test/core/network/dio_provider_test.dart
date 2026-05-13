import 'package:autohub/core/network/dio_provider.dart';
import 'package:autohub/features/auth/application/ports/outbound/session_storage_port.dart';
import 'package:autohub/features/auth/composition/auth_providers.dart';
import 'package:autohub/features/auth/domain/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/fake_http_adapter.dart';

class _InMemorySessionStorage implements SessionStoragePort {
  Session? _session;
  @override
  Future<Session?> read() async => _session;
  @override
  Future<void> write(Session s) async => _session = s;
  @override
  Future<void> clear() async => _session = null;
}

void main() {
  group('dioProvider auth interceptor', () {
    test('injects Authorization header when a session is present', () async {
      final storage = _InMemorySessionStorage();
      await storage.write(Session(
        phone: '+380671234567',
        createdAt: DateTime.utc(2026, 5, 13),
      ));
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 200, body: '[]'),
      );

      final container = ProviderContainer(overrides: [
        sessionStorageProvider.overrideWithValue(storage),
      ]);
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      dio.httpClientAdapter = adapter;

      await dio.get<List<dynamic>>('/vehicles');

      final auth = adapter.requests.single.headers['Authorization'];
      expect(auth, 'Bearer +380671234567');
    });

    test('omits Authorization header when no session', () async {
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 200, body: '[]'),
      );

      final container = ProviderContainer(overrides: [
        sessionStorageProvider.overrideWithValue(_InMemorySessionStorage()),
      ]);
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      dio.httpClientAdapter = adapter;

      await dio.get<List<dynamic>>('/vehicles');

      expect(adapter.requests.single.headers.containsKey('Authorization'),
          isFalse);
    });
  });
}
