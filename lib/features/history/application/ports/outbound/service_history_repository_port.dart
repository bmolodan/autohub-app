import '../../../domain/service_record.dart';

/// Outbound port: source of historical service records for a vehicle.
///
/// Implementations live in `adapters/outbound/` (mock asset reader,
/// HTTP client, local cache, etc.).
abstract interface class ServiceHistoryRepositoryPort {
  /// All closed service records for the current session — aggregated across
  /// every vehicle the customer owns. Used by the History tab.
  Future<List<ServiceRecord>> findAll();

  /// Closed service records filtered to a single vehicle. Used by the per-car
  /// "recent services" preview on the car detail screen.
  Future<List<ServiceRecord>> findByVehicle(String vehicleId);
}
