import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/outbound/mock_service_history_repository.dart';
import '../application/ports/outbound/service_history_repository_port.dart';
import '../application/use_cases/get_service_history.dart';

/// Composition root for the History feature.
///
/// Swap [serviceHistoryRepositoryProvider] override to switch
/// MockServiceHistoryRepository → an HTTP adapter — UI/use-case won't change.
final serviceHistoryRepositoryProvider = Provider<ServiceHistoryRepositoryPort>(
  (_) => const MockServiceHistoryRepository(),
);

final getServiceHistoryUseCaseProvider =
    Provider<GetServiceHistoryUseCase>((ref) {
  return GetServiceHistoryUseCase(
    ref.watch(serviceHistoryRepositoryProvider),
  );
});

/// View-model: runs the use case for a vehicle id and caches the result.
final serviceHistoryProvider = FutureProvider.family
    .autoDispose<GetServiceHistoryOutput, String>((ref, vehicleId) {
  final useCase = ref.watch(getServiceHistoryUseCaseProvider);
  return useCase.execute(GetServiceHistoryInput(vehicleId: vehicleId));
});
