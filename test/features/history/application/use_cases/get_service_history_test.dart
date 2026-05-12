import 'package:autohub/features/history/application/ports/outbound/service_history_repository_port.dart';
import 'package:autohub/features/history/application/use_cases/get_service_history.dart';
import 'package:autohub/features/history/domain/service_record.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake adapter for the outbound port.
class _FakeRepo implements ServiceHistoryRepositoryPort {
  _FakeRepo(this._records);
  final List<ServiceRecord> _records;

  @override
  Future<List<ServiceRecord>> findByVehicle(String vehicleId) async {
    return _records.where((r) => r.vehicleId == vehicleId).toList();
  }
}

ServiceRecord _r(String id, DateTime at, int price, {String vehicleId = 'v1'}) {
  return ServiceRecord(
    id: id,
    title: 'svc-$id',
    completedAt: at,
    priceUah: price,
    vehicleId: vehicleId,
  );
}

void main() {
  group('GetServiceHistoryUseCase', () {
    test('groups records by year-month, newest month first', () async {
      final repo = _FakeRepo([
        _r('a', DateTime(2026, 3, 15), 100),
        _r('b', DateTime(2026, 4, 2), 200),
        _r('c', DateTime(2026, 4, 18), 300),
      ]);
      final useCase = GetServiceHistoryUseCase(repo);

      final out = await useCase.execute(
        const GetServiceHistoryInput(vehicleId: 'v1'),
      );

      expect(out.months, hasLength(2));
      expect(out.months[0].year, 2026);
      expect(out.months[0].month, 4);
      expect(out.months[1].month, 3);
    });

    test('sorts records within a month newest-first', () async {
      final repo = _FakeRepo([
        _r('a', DateTime(2026, 4, 2), 100),
        _r('b', DateTime(2026, 4, 18), 200),
      ]);
      final useCase = GetServiceHistoryUseCase(repo);

      final out = await useCase.execute(
        const GetServiceHistoryInput(vehicleId: 'v1'),
      );

      expect(out.months[0].records.map((r) => r.id), ['b', 'a']);
    });

    test('sums prices across all months', () async {
      final repo = _FakeRepo([
        _r('a', DateTime(2026, 3, 15), 100),
        _r('b', DateTime(2026, 4, 2), 250),
      ]);
      final useCase = GetServiceHistoryUseCase(repo);

      final out = await useCase.execute(
        const GetServiceHistoryInput(vehicleId: 'v1'),
      );

      expect(out.totalUah, 350);
    });

    test('filters records by vehicleId via the port', () async {
      final repo = _FakeRepo([
        _r('a', DateTime(2026, 4, 1), 100, vehicleId: 'v1'),
        _r('b', DateTime(2026, 4, 2), 200, vehicleId: 'v2'),
      ]);
      final useCase = GetServiceHistoryUseCase(repo);

      final out = await useCase.execute(
        const GetServiceHistoryInput(vehicleId: 'v1'),
      );

      expect(out.totalUah, 100);
      expect(out.months.single.records.single.id, 'a');
    });
  });
}
