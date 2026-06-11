import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_environment.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/shared_prefs_provider.dart';
import '../../auth/composition/auth_providers.dart';
import '../../cars/composition/cars_providers.dart';
import '../../orders/composition/orders_providers.dart';
import '../adapters/outbound/http_client_profile_repository.dart';
import '../adapters/outbound/shared_prefs_client_profile_repository.dart';
import '../application/ports/outbound/client_profile_repository_port.dart';
import '../application/use_cases/get_client_profile.dart';
import '../application/use_cases/save_client_profile.dart';
import '../application/use_cases/wipe_account.dart';
import '../domain/client_profile.dart';

/// Storage for the client profile (name, email). In remote mode the data is
/// derived from RoApp on every read (via GET /v1/profile); in local mode it
/// persists to SharedPrefs and is editable through RegisterClientScreen.
final clientProfileRepositoryProvider = Provider<ClientProfileRepositoryPort>(
  (ref) {
    return switch (ref.watch(appEnvironmentProvider)) {
      AppEnvironment.remote =>
        HttpClientProfileRepository(ref.watch(dioProvider)),
      AppEnvironment.local => SharedPrefsClientProfileRepository(
          ref.watch(sharedPreferencesProvider),
        ),
    };
  },
);

final getClientProfileUseCaseProvider = Provider<GetClientProfileUseCase>(
  (ref) => GetClientProfileUseCase(ref.watch(clientProfileRepositoryProvider)),
);

final saveClientProfileUseCaseProvider = Provider<SaveClientProfileUseCase>(
  (ref) => SaveClientProfileUseCase(ref.watch(clientProfileRepositoryProvider)),
);

final wipeAccountUseCaseProvider = Provider<WipeAccountUseCase>(
  (ref) => WipeAccountUseCase(
    orders: ref.watch(activeOrderRepositoryProvider),
    vehicles: ref.watch(vehicleRepositoryProvider),
    profile: ref.watch(clientProfileRepositoryProvider),
    session: ref.watch(sessionStorageProvider),
    photos: ref.watch(photoStorageProvider),
  ),
);

/// Current client's profile, scoped to the active session's phone.
/// Resolves to null when:
///   - no session (signed out), or
///   - session exists but no profile is saved for that phone yet.
class ClientProfileController extends AsyncNotifier<ClientProfile?> {
  @override
  Future<ClientProfile?> build() async {
    // Watch the sync state, not the future — this lets us short-circuit on
    // signed-out without an AsyncLoading window that the router redirect
    // would have to special-case.
    final session = ref.watch(authControllerProvider).asData?.value;
    if (session == null) return null;
    return ref.read(getClientProfileUseCaseProvider).execute(session.phone);
  }

  Future<ClientProfile> save({required String name, String? email}) async {
    final session = await ref.read(authControllerProvider.future);
    if (session == null) {
      throw StateError('Cannot save profile without an active session');
    }
    final saved = await ref.read(saveClientProfileUseCaseProvider).execute(
          SaveClientProfileInput(
            phone: session.phone,
            name: name,
            email: email,
          ),
        );
    state = AsyncData(saved);
    return saved;
  }
}

final clientProfileControllerProvider =
    AsyncNotifierProvider<ClientProfileController, ClientProfile?>(
  ClientProfileController.new,
);
