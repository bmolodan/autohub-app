import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/shared_prefs_provider.dart';
import '../../auth/composition/auth_providers.dart';
import '../adapters/outbound/shared_prefs_client_profile_repository.dart';
import '../application/ports/outbound/client_profile_repository_port.dart';
import '../application/use_cases/get_client_profile.dart';
import '../application/use_cases/save_client_profile.dart';
import '../domain/client_profile.dart';

/// Storage for the registered client (name, email). Single-tenant for now
/// — keyed by the session's phone so a phone swap re-prompts onboarding.
final clientProfileRepositoryProvider = Provider<ClientProfileRepositoryPort>(
  (ref) => SharedPrefsClientProfileRepository(
    ref.watch(sharedPreferencesProvider),
  ),
);

final getClientProfileUseCaseProvider = Provider<GetClientProfileUseCase>(
  (ref) => GetClientProfileUseCase(ref.watch(clientProfileRepositoryProvider)),
);

final saveClientProfileUseCaseProvider = Provider<SaveClientProfileUseCase>(
  (ref) => SaveClientProfileUseCase(ref.watch(clientProfileRepositoryProvider)),
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
