import '../../../domain/vehicle.dart';

/// Outbound port — capability, not technology. Adapter implementations
/// live in `adapters/outbound/` (in-memory, http, hive, etc.).
abstract interface class VehicleRepositoryPort {
  Future<List<Vehicle>> findAll();
  Future<Vehicle?> findById(String id);
  Future<void> save(Vehicle vehicle);

  /// Removes the vehicle with [id]. No-op if it doesn't exist.
  Future<void> delete(String id);

  /// Wipes ALL vehicles for the current account. Used by the account-
  /// deletion flow.
  Future<void> clear();
}
