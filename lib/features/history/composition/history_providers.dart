import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_environment.dart';
import '../../../core/network/dio_provider.dart';
import '../adapters/outbound/http_service_history_repository.dart';
import '../adapters/outbound/mock_service_history_repository.dart';
import '../application/ports/outbound/service_history_repository_port.dart';
import '../application/use_cases/get_service_history.dart';

/// Composition root for the History feature.
final serviceHistoryRepositoryProvider =
    Provider<ServiceHistoryRepositoryPort>((ref) {
  return switch (ref.watch(appEnvironmentProvider)) {
    AppEnvironment.remote =>
      HttpServiceHistoryRepository(ref.watch(dioProvider)),
    AppEnvironment.local => const MockServiceHistoryRepository(),
  };
});

final getServiceHistoryUseCaseProvider =
    Provider<GetServiceHistoryUseCase>((ref) {
  return GetServiceHistoryUseCase(
    ref.watch(serviceHistoryRepositoryProvider),
  );
});

/// View-model: per-vehicle history. Cached for the session — closed orders
/// rarely change in real time, and tab switches shouldn't re-fetch. Cleared
/// explicitly by AuthController on logout via _invalidateSessionScopedData.
final serviceHistoryProvider = FutureProvider.family
    .autoDispose<GetServiceHistoryOutput, String>((ref, vehicleId) {
  // autoDispose with keepAlive: cleared on family invalidate (logout) but
  // not dropped when the screen briefly unsubscribes during navigation.
  ref.keepAlive();
  final useCase = ref.watch(getServiceHistoryUseCaseProvider);
  return useCase.execute(GetServiceHistoryInput(vehicleId: vehicleId));
});

/// View-model: aggregated history across every vehicle the customer owns.
/// Used by the History tab. Cached the same way as the per-vehicle variant.
final aggregatedServiceHistoryProvider =
    FutureProvider.autoDispose<GetServiceHistoryOutput>((ref) {
  ref.keepAlive();
  return ref.watch(getServiceHistoryUseCaseProvider).executeAll();
});
