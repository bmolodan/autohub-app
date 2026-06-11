import 'package:autohub/features/history/adapters/inbound/history_screen.dart';
import 'package:autohub/features/history/application/ports/outbound/service_history_repository_port.dart';
import 'package:autohub/features/history/composition/history_providers.dart';
import 'package:autohub/features/history/domain/service_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../_helpers/test_app.dart';

/// In-memory repository for deterministic widget tests — avoids the
/// `rootBundle.loadString` async timing dance that the asset-backed mock
/// adapter brings.
class _SeededRepo implements ServiceHistoryRepositoryPort {
  _SeededRepo(this._records);
  final List<ServiceRecord> _records;
  @override
  Future<List<ServiceRecord>> findAll() async => List.of(_records);
  @override
  Future<List<ServiceRecord>> findByVehicle(String vehicleId) async =>
      _records.where((r) => r.vehicleId == vehicleId).toList();
}

const _vehicle = ServiceVehicleRef(
  make: 'Mitsubishi',
  model: 'Pajero',
  plate: 'JMB',
);

ServiceRecord _record(int i) {
  // Spread across 5 months so month grouping is exercised. Newest first
  // when sorted: id=0 is the most recent.
  final daysAgo = i * 4;
  return ServiceRecord(
    id: 'h-$i',
    title: 'Робота #$i',
    completedAt: DateTime.utc(2026, 1, 1).subtract(Duration(days: daysAgo)),
    vehicleId: 'v-1',
    vehicle: _vehicle,
  );
}

void main() {
  group('HistoryScreen', () {
    testWidgets('renders title + records', (tester) async {
      final repo = _SeededRepo(List.generate(5, _record));
      await pumpScreen(
        tester,
        child: const HistoryScreen(vehicleId: 'v-1'),
        overrides: [
          serviceHistoryRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Історія'), findsOneWidget);
      expect(find.text('Робота #0'), findsOneWidget); // newest
      expect(find.text('Робота #4'), findsOneWidget); // oldest (5 total)
      // No pagination footer when totalRecords <= 20.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // No pricing anywhere.
      expect(find.textContaining('₴'), findsNothing);
    });

    testWidgets('paginates: oldest record only renders after scroll triggers next batch', (tester) async {
      // 25 records, page size = 20. First render slices to 20: items 0..19.
      // Item 24 ("Робота #24") is not in the sliced model and CANNOT appear
      // anywhere in the widget tree until scroll bumps visibleCount.
      final repo = _SeededRepo(List.generate(25, _record));
      await pumpScreen(
        tester,
        child: const HistoryScreen(vehicleId: 'v-1'),
        overrides: [
          serviceHistoryRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Top of the list is rendered.
      expect(find.text('Робота #0'), findsOneWidget);
      // Item 24 is sliced out of the model — find can't see it.
      expect(find.text('Робота #24'), findsNothing);

      // Scroll to bottom, which trips the prefetch listener and rebuilds
      // with visibleCount=40 (clamped by model to 25).
      await tester.scrollUntilVisible(
        find.text('Робота #24'),
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 100,
      );
      expect(find.text('Робота #24'), findsOneWidget);
    });
  });
}
