import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Replaces Dio's underlying transport with a function. Each test
/// provides its own [handler] that maps a RequestOptions to a canned
/// Response.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);

  final FakeResponse Function(RequestOptions) handler;

  /// Records every RequestOptions for `expect()`-driven assertions.
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final response = handler(options);
    final bytes = utf8.encode(response.body);
    return ResponseBody.fromBytes(
      bytes,
      response.statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class FakeResponse {
  const FakeResponse({required this.statusCode, required this.body});
  final int statusCode;
  final String body;

  factory FakeResponse.json(int statusCode, Object body) =>
      FakeResponse(statusCode: statusCode, body: jsonEncode(body));
}

/// Convenience constructor for a Dio wired to [adapter].
Dio dioWith(FakeHttpAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'));
  dio.httpClientAdapter = adapter;
  return dio;
}
