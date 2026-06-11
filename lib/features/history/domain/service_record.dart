/// A completed service record in the user's history.
///
/// Pure value object — no Flutter, no infra. Equality by [id].
///
/// Pricing intentionally absent: the middleware strips prices per product rule
/// ("client never sees totals, prices, or service catalog items"), so this
/// model cannot carry them.
class ServiceRecord {
  const ServiceRecord({
    required this.id,
    required this.title,
    required this.completedAt,
    required this.vehicleId,
    required this.vehicle,
  });

  final String id;
  final String title;
  final DateTime completedAt;
  final String vehicleId;
  final ServiceVehicleRef vehicle;

  @override
  bool operator ==(Object other) => other is ServiceRecord && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The vehicle slice carried inline on each service record. Saves a parallel
/// `/v1/vehicles` round-trip when rendering the aggregated history list.
class ServiceVehicleRef {
  const ServiceVehicleRef({
    required this.make,
    required this.model,
    required this.plate,
  });

  final String make;
  final String model;
  final String plate;

  String get label => '$make $model'.trim();

  @override
  bool operator ==(Object other) =>
      other is ServiceVehicleRef &&
      other.make == make &&
      other.model == model &&
      other.plate == plate;

  @override
  int get hashCode => Object.hash(make, model, plate);
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
}
