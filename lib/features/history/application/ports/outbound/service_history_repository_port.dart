import '../../../domain/service_record.dart';

/// Outbound port: source of historical service records for a vehicle.
///
/// Implementations live in `adapters/outbound/` (mock asset reader,
/// HTTP client, local cache, etc.).
abstract interface class ServiceHistoryRepositoryPort {
  Future<List<ServiceRecord>> findByVehicle(String vehicleId);
}
