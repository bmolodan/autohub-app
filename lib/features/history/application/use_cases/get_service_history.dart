import '../../domain/service_record.dart';
import '../ports/outbound/service_history_repository_port.dart';

class GetServiceHistoryInput {
  const GetServiceHistoryInput({required this.vehicleId});
  final String vehicleId;
}

class GetServiceHistoryOutput {
  const GetServiceHistoryOutput({
    required this.months,
    required this.totalUah,
  });

  final List<ServiceHistoryMonth> months;
  final int totalUah;
}

/// Loads a vehicle's service history grouped by year-month, newest first,
/// and reports the all-time total.
class GetServiceHistoryUseCase {
  const GetServiceHistoryUseCase(this._repository);

  final ServiceHistoryRepositoryPort _repository;

  Future<GetServiceHistoryOutput> execute(
    GetServiceHistoryInput input,
  ) async {
    final records = await _repository.findByVehicle(input.vehicleId);
    final months = _groupByMonth(records);
    final total = records.fold<int>(0, (sum, r) => sum + r.priceUah);
    return GetServiceHistoryOutput(months: months, totalUah: total);
  }

  List<ServiceHistoryMonth> _groupByMonth(List<ServiceRecord> records) {
    final byKey = <String, List<ServiceRecord>>{};
    for (final r in records) {
      final key = '${r.completedAt.year}-${r.completedAt.month}';
      byKey.putIfAbsent(key, () => []).add(r);
    }

    final months = byKey.entries.map((e) {
      final any = e.value.first;
      final sorted = [...e.value]
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return ServiceHistoryMonth(
        year: any.completedAt.year,
        month: any.completedAt.month,
        records: sorted,
      );
    }).toList()
      ..sort((a, b) {
        final cy = b.year.compareTo(a.year);
        return cy != 0 ? cy : b.month.compareTo(a.month);
      });

    return months;
  }
}
