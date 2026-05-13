import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/shared_prefs_provider.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/id_generator.dart';
import '../adapters/outbound/_seed.dart';
import '../adapters/outbound/shared_prefs_active_order_repository.dart';
import '../application/ports/outbound/active_order_repository_port.dart';
import '../application/use_cases/cancel_order.dart';
import '../application/use_cases/create_order.dart';
import '../application/use_cases/get_active_orders.dart';
import '../application/use_cases/get_order_by_id.dart';
import '../application/use_cases/update_order_progress.dart';
import '../domain/active_order.dart';

/// Composition root for the orders feature.
final activeOrderRepositoryProvider = Provider<ActiveOrderRepositoryPort>(
  (ref) {
    final clock = ref.watch(clockProvider);
    return SharedPrefsActiveOrderRepository(
      ref.watch(sharedPreferencesProvider),
      seedBuilder: () => buildActiveOrdersSeedJson(clock),
    );
  },
);

final getActiveOrdersUseCaseProvider = Provider<GetActiveOrdersUseCase>(
  (ref) => GetActiveOrdersUseCase(ref.watch(activeOrderRepositoryProvider)),
);

final getOrderByIdUseCaseProvider = Provider<GetOrderByIdUseCase>(
  (ref) => GetOrderByIdUseCase(ref.watch(activeOrderRepositoryProvider)),
);

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>(
  (ref) => CreateOrderUseCase(
    ref.watch(activeOrderRepositoryProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final cancelOrderUseCaseProvider = Provider<CancelOrderUseCase>(
  (ref) => CancelOrderUseCase(
    ref.watch(activeOrderRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final updateOrderProgressUseCaseProvider = Provider<UpdateOrderProgressUseCase>(
  (ref) => UpdateOrderProgressUseCase(
    ref.watch(activeOrderRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

/// View-model: the active-orders list. Notifier so the booking flow can
/// add new orders and the Home screen re-renders without polling.
class OrdersController extends AsyncNotifier<List<ActiveOrder>> {
  @override
  Future<List<ActiveOrder>> build() {
    return ref.watch(getActiveOrdersUseCaseProvider).execute();
  }

  Future<ActiveOrder> create(CreateOrderInput input) async {
    final created = await ref.read(createOrderUseCaseProvider).execute(input);
    final current = state.valueOrNull ?? const <ActiveOrder>[];
    state = AsyncData([...current, created]);
    return created;
  }

  Future<ActiveOrder> cancel(String id) async {
    final updated = await ref
        .read(cancelOrderUseCaseProvider)
        .execute(CancelOrderInput(id: id));
    state = AsyncData(_replaceOrAppend(updated));
    ref.invalidate(orderByIdProvider(id));
    return updated;
  }

  Future<ActiveOrder> updateProgress(
    String id,
    double progress, {
    OrderStage? newStage,
    String? newStageLabel,
  }) async {
    final updated = await ref.read(updateOrderProgressUseCaseProvider).execute(
          UpdateOrderProgressInput(
            id: id,
            progress: progress,
            newStage: newStage,
            newStageLabel: newStageLabel,
          ),
        );
    state = AsyncData(_replaceOrAppend(updated));
    ref.invalidate(orderByIdProvider(id));
    return updated;
  }

  /// Replace the order with the same id; append if it isn't present
  /// (handles races where the list was rebuilt between use-case completion
  /// and the state write).
  List<ActiveOrder> _replaceOrAppend(ActiveOrder updated) {
    final current = state.valueOrNull ?? const <ActiveOrder>[];
    final replaced = [
      for (final o in current) o.id == updated.id ? updated : o,
    ];
    return replaced.any((o) => o.id == updated.id)
        ? replaced
        : [...replaced, updated];
  }
}

final ordersControllerProvider =
    AsyncNotifierProvider<OrdersController, List<ActiveOrder>>(
  OrdersController.new,
);

final orderByIdProvider =
    FutureProvider.family.autoDispose<ActiveOrder?, String>((ref, id) {
  return ref
      .watch(getOrderByIdUseCaseProvider)
      .execute(GetOrderByIdInput(id: id));
});
