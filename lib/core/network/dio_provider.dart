import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/ports/outbound/session_storage_port.dart';
import '../../features/auth/composition/auth_providers.dart';
import '../../features/auth/domain/session.dart';
import '../config/app_environment.dart';
import '../util/jwt_payload.dart';

/// Set on `RequestOptions.extra` to bypass the auth + refresh interceptors —
/// used by /auth/refresh itself and by the retry-after-refresh path so they
/// don't recurse.
const String _skipAuth = 'autohub.skipAuth';

/// How close to `accessExpiresAt` we proactively refresh before sending.
const Duration _refreshSkew = Duration(seconds: 30);

/// Configured Dio for HTTP adapters.
///
/// Two interceptors:
///   1. Request — injects `Authorization: Bearer <accessToken>` from the
///      stored session. Proactively refreshes the access token if it's
///      within [_refreshSkew] of expiry.
///   2. Error — on `401`, calls `POST /auth/refresh` with the stored
///      refresh token and retries the original request. On refresh failure
///      it clears the session (router-redirect on stale state lives elsewhere).
///
/// Concurrent 401s share a single in-flight refresh via [_RefreshGate]
/// so we don't fan out N refresh calls for N parallel requests.
final dioProvider = Provider<Dio>((ref) {
  final sessionStorage = ref.watch(sessionStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ref.watch(apiBaseUrlProvider),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final gate = _RefreshGate();

  Future<Session?> refresh(Session current) {
    return gate.run(() => _doRefresh(dio, sessionStorage, current));
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.extra[_skipAuth] == true) {
          handler.next(options);
          return;
        }
        var session = await sessionStorage.read();
        if (session != null &&
            session.accessExpiresAt.difference(DateTime.now().toUtc()) <
                _refreshSkew) {
          session = await refresh(session);
        }
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.requestOptions.extra[_skipAuth] == true ||
            error.response?.statusCode != 401) {
          handler.next(error);
          return;
        }
        final session = await sessionStorage.read();
        if (session == null) {
          handler.next(error);
          return;
        }
        final refreshed = await refresh(session);
        if (refreshed == null) {
          handler.next(error);
          return;
        }
        try {
          final retryOptions = error.requestOptions.copyWith(
            headers: {
              ...error.requestOptions.headers,
              'Authorization': 'Bearer ${refreshed.accessToken}',
            },
            extra: {
              ...error.requestOptions.extra,
              _skipAuth: true,
            },
          );
          final retried = await dio.fetch<dynamic>(retryOptions);
          handler.resolve(retried);
        } on DioException catch (e) {
          handler.next(e);
        }
      },
    ),
  );

  return dio;
});

Future<Session?> _doRefresh(
  Dio dio,
  SessionStoragePort sessionStorage,
  Session current,
) async {
  try {
    final res = await dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': current.refreshToken},
      options: Options(extra: {_skipAuth: true}),
    );
    final m = res.data;
    if (m == null) {
      await sessionStorage.clear();
      return null;
    }
    final accessToken = m['accessToken'] as String;
    final updated = current.copyWith(
      accessToken: accessToken,
      refreshToken: m['refreshToken'] as String,
      accessExpiresAt: jwtExpiresAt(accessToken),
    );
    await sessionStorage.write(updated);
    return updated;
  } on DioException catch (_) {
    await sessionStorage.clear();
    return null;
  }
}

/// Coalesces concurrent refresh attempts into a single in-flight Future.
class _RefreshGate {
  Future<Session?>? _current;
  Future<Session?> run(Future<Session?> Function() doRefresh) {
    return _current ??= doRefresh().whenComplete(() => _current = null);
  }
}
