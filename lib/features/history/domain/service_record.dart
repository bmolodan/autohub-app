/// A completed service record in the user's history.
///
/// Pure value object — no Flutter, no infra. Equality by [id].
class ServiceRecord {
  const ServiceRecord({
    required this.id,
    required this.title,
    required this.completedAt,
    required this.priceUah,
    required this.vehicleId,
  });

  final String id;
  final String title;
  final DateTime completedAt;
  final int priceUah;
  final String vehicleId;

  @override
  bool operator ==(Object other) => other is ServiceRecord && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// History grouped by year-month, ordered newest-first inside each group.
class ServiceHistoryMonth {
  const ServiceHistoryMonth({
    required this.year,
    required this.month,
    required this.records,
  });

  final int year;
  final int month;
  final List<ServiceRecord> records;

  int get totalUah => records.fold(0, (sum, r) => sum + r.priceUah);
}
