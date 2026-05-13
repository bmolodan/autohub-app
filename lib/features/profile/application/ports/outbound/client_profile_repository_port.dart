import '../../../domain/client_profile.dart';

/// Outbound port — storage for the current user's profile. Keyed by phone
/// number so multiple-account swaps stay correct.
abstract interface class ClientProfileRepositoryPort {
  Future<ClientProfile?> findByPhone(String phone);
  Future<void> save(ClientProfile profile);
}
