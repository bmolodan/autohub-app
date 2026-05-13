import '../../../auth/application/ports/outbound/session_storage_port.dart';
import '../../../cars/application/ports/outbound/vehicle_repository_port.dart';
import '../../../orders/application/ports/outbound/active_order_repository_port.dart';
import '../../../orders/application/ports/outbound/photo_storage_port.dart';
import '../ports/outbound/client_profile_repository_port.dart';

/// Wipes all locally-persisted personal data for the current account:
/// session, profile, vehicles, active orders + their photo files.
///
/// Photo files are best-effort — any individual failure is swallowed so
/// the SharedPreferences wipe still proceeds.
///
/// Wipe order: photos first (so the order records still reference them),
/// then orders, then vehicles, profile, session. Session last so the
/// router doesn't bounce mid-wipe.
class WipeAccountUseCase {
  const WipeAccountUseCase({
    required ActiveOrderRepositoryPort orders,
    required VehicleRepositoryPort vehicles,
    required ClientProfileRepositoryPort profile,
    required SessionStoragePort session,
    required PhotoStoragePort photos,
  })  : _orders = orders,
        _vehicles = vehicles,
        _profile = profile,
        _session = session,
        _photos = photos;

  final ActiveOrderRepositoryPort _orders;
  final VehicleRepositoryPort _vehicles;
  final ClientProfileRepositoryPort _profile;
  final SessionStoragePort _session;
  final PhotoStoragePort _photos;

  Future<void> execute() async {
    // 1. Photos referenced by stored orders.
    final allOrders = await _orders.findAll();
    for (final order in allOrders) {
      for (final photo in order.photos) {
        try {
          await _photos.remove(photo);
        } on Object catch (_) {
          // Best-effort: a missing file or permission glitch can't block
          // the data wipe.
        }
      }
    }

    // 2. Plaintext storage.
    await _orders.clear();
    await _vehicles.clear();
    await _profile.clear();
    await _session.clear();
  }
}
