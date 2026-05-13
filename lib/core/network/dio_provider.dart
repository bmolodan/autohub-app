import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/composition/auth_providers.dart';
import '../config/app_environment.dart';

/// Configured Dio for HTTP adapters.
///
/// Auth interceptor reads the current session from `sessionStorageProvider`
/// and injects `Authorization: Bearer <phone>` (placeholder until real
/// JWTs land). Tests override this provider with a `Dio` wired to a
/// `_FakeHttpAdapter`.
final dioProvider = Provider<Dio>((ref) {
  // Capture the resolved port at build time so the async interceptor
  // doesn't reach back into a stale Riverpod ref across HTTP requests.
  final sessionStorage = ref.watch(sessionStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final session = await sessionStorage.read();
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.phone}';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
});
