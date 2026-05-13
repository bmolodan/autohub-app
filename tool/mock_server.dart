// Dart-only mock server for local dev. Run:
//   dart run tool/mock_server.dart
// Then start the app against it:
//   flutter run --dart-define=APP_ENV=remote --dart-define=API_URL=http://localhost:8080
//
// Endpoints mirror docs/api/openapi.yaml. State is in-memory only and
// resets on restart.
//
// CLI script — print is intentional; lint relaxations only here.
// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await io.serve(_makeHandler(), 'localhost', port);
  print(
      'Mock server listening on http://${server.address.host}:${server.port}');
}

Handler _makeHandler() {
  final router = Router();
  final state = _State();

  router.post('/auth/otp/request', (Request req) async {
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final phone = body['phone'] as String;
    final ch = 'ch-${DateTime.now().millisecondsSinceEpoch}';
    state.challenges[ch] = phone;
    return Response.ok(
      jsonEncode({'challengeId': ch, 'phone': phone}),
      headers: _jsonHeaders,
    );
  });

  router.post('/auth/otp/verify', (Request req) async {
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final code = body['code'] as String;
    final challengeId = body['challengeId'] as String;
    final phone = state.challenges[challengeId];
    if (phone == null || code != '0000') {
      return Response(
        401,
        body: jsonEncode({'error': 'invalid_code'}),
        headers: _jsonHeaders,
      );
    }
    return Response.ok(
      jsonEncode(
          {'phone': phone, 'createdAt': DateTime.now().toIso8601String()}),
      headers: _jsonHeaders,
    );
  });

  router.get('/vehicles', (Request req) async {
    return Response.ok(jsonEncode(state.vehicles), headers: _jsonHeaders);
  });

  router.get('/vehicles/<id>', (Request req, String id) async {
    final v = state.vehicles.where((m) => m['id'] == id).firstOrNull;
    return v == null
        ? Response.notFound('not found')
        : Response.ok(jsonEncode(v), headers: _jsonHeaders);
  });

  router.post('/vehicles', (Request req) async {
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    state.vehicles.removeWhere((m) => m['id'] == body['id']);
    state.vehicles.add(body);
    return Response(201, body: jsonEncode(body), headers: _jsonHeaders);
  });

  router.get('/orders', (Request req) async {
    return Response.ok(jsonEncode(state.orders), headers: _jsonHeaders);
  });

  router.get('/orders/<id>', (Request req, String id) async {
    final o = state.orders.where((m) => m['id'] == id).firstOrNull;
    return o == null
        ? Response.notFound('not found')
        : Response.ok(jsonEncode(o), headers: _jsonHeaders);
  });

  router.post('/orders', (Request req) async {
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    state.orders.removeWhere((m) => m['id'] == body['id']);
    state.orders.add(body);
    return Response(201, body: jsonEncode(body), headers: _jsonHeaders);
  });

  router.get('/history/<vehicleId>', (Request req, String vehicleId) async {
    return Response.ok(
      jsonEncode(
          state.history.where((m) => m['vehicle_id'] == vehicleId).toList()),
      headers: _jsonHeaders,
    );
  });

  return Pipeline().addMiddleware(logRequests()).addHandler(router.call);
}

const Map<String, String> _jsonHeaders = {'content-type': 'application/json'};

class _State {
  final Map<String, String> challenges = {};

  final List<Map<String, dynamic>> vehicles = [
    {
      'id': 'v-camry-1',
      'make': 'Toyota',
      'model': 'Camry',
      'year': 2018,
      'plate': 'AA 1234 BC',
      'vin': 'JT2BG28K3X0123456',
      'mileageKm': 87500,
      'nextServiceMileageKm': 90000,
    },
  ];

  final List<Map<String, dynamic>> orders = [
    {
      'id': '4521',
      'title': 'Заміна гальмівних колодок',
      'status': 'in_progress',
      'status_label': 'У ремонті',
      'vehicle': {'make': 'Toyota', 'model': 'Camry', 'plate': 'AA 1234 BC'},
      'progress': 0.6,
      'eta': '2026-05-13T14:00:00+03:00',
      'total_uah': 2850,
      'timeline': [
        {
          'stage': 'accepted',
          'label': 'Прийнято',
          'at': '2026-05-13T10:24:00+03:00'
        },
      ],
      'photos': <Map<String, dynamic>>[],
    },
  ];

  final List<Map<String, dynamic>> history = [
    {
      'id': 'h-1001',
      'title': 'ТО-15000',
      'completed_at': '2026-04-18T11:30:00+03:00',
      'price_uah': 2400,
      'vehicle_id': 'v-camry-1',
    },
  ];
}
