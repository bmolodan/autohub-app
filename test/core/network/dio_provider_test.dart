import 'dart:convert';

import 'package:autohub/core/network/dio_provider.dart';
import 'package:autohub/features/auth/composition/auth_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/fake_http_adapter.dart';
import '../../_helpers/in_memory_session_storage.dart';

String _jwt(Map<String, dynamic> payload) {
  String b64(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${b64({'alg': 'HS256', 'typ': 'JWT'})}.${b64(payload)}.sig';
}

String _futureJwt({Duration inFromNow = const Duration(hours: 1)}) =>
    _jwt({
      'sub': 'acc-1',
      'phone': '+380671234567',
      'exp': DateTime.now().toUtc().add(inFromNow).millisecondsSinceEpoch ~/ 1000,
    });

void main() {
  group('dioProvider — request interceptor', () {
    test('injects Bearer <accessToken> when a session is present', () async {
      final access = _futureJwt();
      final storage = InMemorySessionStorage(testSession(accessToken: access));
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

      expect(adapter.requests.single.headers['Authorization'], 'Bearer $access');
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

    test('proactively refreshes when accessToken is near expiry', () async {
      final newAccess = _futureJwt();
      final storage = InMemorySessionStorage(
        testSession(
          accessToken: _futureJwt(inFromNow: const Duration(seconds: 5)),
          accessExpiresAt: DateTime.now().toUtc().add(const Duration(seconds: 5)),
        ),
      );
      final adapter = FakeHttpAdapter((options) {
        if (options.path == '/auth/refresh') {
          return FakeResponse.json(200, {
            'accessToken': newAccess,
            'refreshToken': 'rt-2',
            'profile': {'phone': '+380671234567', 'personId': null},
          });
        }
        return const FakeResponse(statusCode: 200, body: '[]');
      });

      final container = ProviderContainer(overrides: [
        sessionStorageProvider.overrideWithValue(storage),
      ]);
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      dio.httpClientAdapter = adapter;

      await dio.get<List<dynamic>>('/vehicles');

      // Two requests: refresh, then /vehicles with the new token.
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests[0].path, '/auth/refresh');
      expect(adapter.requests[1].path, '/vehicles');
      expect(adapter.requests[1].headers['Authorization'], 'Bearer $newAccess');
      expect((await storage.read())!.accessToken, newAccess);
    });
  });

  group('dioProvider — 401 refresh-and-retry', () {
    test('refreshes once on 401 and replays the request with the new token',
        () async {
      final newAccess = _futureJwt();
      final storage = InMemorySessionStorage(testSession(accessToken: 'old'));

      var vehiclesHits = 0;
      final adapter = FakeHttpAdapter((options) {
        if (options.path == '/auth/refresh') {
          return FakeResponse.json(200, {
            'accessToken': newAccess,
            'refreshToken': 'rt-2',
            'profile': {'phone': '+380671234567', 'personId': null},
          });
        }
        if (options.path == '/vehicles') {
          vehiclesHits++;
          if (vehiclesHits == 1) {
            return const FakeResponse(statusCode: 401, body: '');
          }
          return const FakeResponse(statusCode: 200, body: '["truck-1"]');
        }
        return const FakeResponse(statusCode: 404, body: '');
      });

      final container = ProviderContainer(overrides: [
        sessionStorageProvider.overrideWithValue(storage),
      ]);
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      dio.httpClientAdapter = adapter;

      final response = await dio.get<List<dynamic>>('/vehicles');

      expect(response.statusCode, 200);
      // /vehicles, /auth/refresh, /vehicles (retry)
      expect(adapter.requests.map((r) => r.path).toList(),
          ['/vehicles', '/auth/refresh', '/vehicles']);
      expect(adapter.requests[2].headers['Authorization'], 'Bearer $newAccess');
      expect((await storage.read())!.accessToken, newAccess);
    });

    test('parallel 401s share a single refresh call', () async {
      final newAccess = _futureJwt();
      final storage = InMemorySessionStorage(testSession(accessToken: 'old'));

      var refreshHits = 0;
      final firstHitPerPath = <String>{};
      final adapter = FakeHttpAdapter((options) {
        if (options.path == '/auth/refresh') {
          refreshHits++;
          return FakeResponse.json(200, {
            'accessToken': newAccess,
            'refreshToken': 'rt-2',
            'profile': {'phone': '+380671234567', 'personId': null},
          });
        }
        // First hit for each path: 401. Second hit: 200.
        final isFirst = firstHitPerPath.add(options.path);
        return isFirst
            ? const FakeResponse(statusCode: 401, body: '')
            : const FakeResponse(statusCode: 200, body: '[]');
      });

      final container = ProviderContainer(overrides: [
        sessionStorageProvider.overrideWithValue(storage),
      ]);
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      dio.httpClientAdapter = adapter;

      await Future.wait([
        dio.get<List<dynamic>>('/vehicles'),
        dio.get<List<dynamic>>('/orders'),
        dio.get<List<dynamic>>('/history'),
      ]);

      expect(refreshHits, 1, reason: 'three parallel 401s should share refresh');
      // 3 initial 401s + 1 refresh + 3 retries = 7
      expect(adapter.requests, hasLength(7));
    });

    test('clears session and propagates the error when refresh also fails',
        () async {
      final storage = InMemorySessionStorage(testSession(accessToken: 'old'));
      final adapter = FakeHttpAdapter((options) {
        return const FakeResponse(statusCode: 401, body: '');
      });

      final container = ProviderContainer(overrides: [
        sessionStorageProvider.overrideWithValue(storage),
      ]);
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      dio.httpClientAdapter = adapter;

      await expectLater(
        () => dio.get<List<dynamic>>('/vehicles'),
        throwsA(isA<DioException>()),
      );
      expect(await storage.read(), isNull);
    });

    test('does not refresh on non-401 errors', () async {
      final storage = InMemorySessionStorage(testSession(accessToken: 'old'));
      final adapter = FakeHttpAdapter(
        (_) => const FakeResponse(statusCode: 500, body: ''),
      );

      final container = ProviderContainer(overrides: [
        sessionStorageProvider.overrideWithValue(storage),
      ]);
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      dio.httpClientAdapter = adapter;

      await expectLater(
        () => dio.get<List<dynamic>>('/vehicles'),
        throwsA(isA<DioException>()),
      );
      // Only the original request — no refresh attempt.
      expect(adapter.requests, hasLength(1));
      expect((await storage.read())?.accessToken, 'old');
    });
  });
}
