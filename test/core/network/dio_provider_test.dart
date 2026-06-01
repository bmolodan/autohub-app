import 'package:autohub/core/network/dio_provider.dart';
import 'package:autohub/features/auth/composition/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/fake_http_adapter.dart';
import '../../_helpers/in_memory_session_storage.dart';

void main() {
  group('dioProvider auth interceptor', () {
    test('injects Authorization header when a session is present', () async {
      final storage = InMemorySessionStorage(testSession(accessToken: 'jwt-1'));
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
      // NOTE: dio_provider still sends `Bearer ${session.phone}` as a
      // placeholder. Phase 2 Task #3 switches it to ${session.accessToken}
      // alongside the 401-refresh interceptor — this expectation will
      // flip then.
      expect(auth, 'Bearer +380671234567');
    });

    test('omits Authorization header when no session', () async {
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 200, body: '[]'),
      );

      final container = ProviderContainer(overrides: [
        sessionStorageProvider.overrideWithValue(InMemorySessionStorage()),
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
