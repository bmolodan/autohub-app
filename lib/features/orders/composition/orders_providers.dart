import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/shared_prefs_provider.dart';
import '../adapters/outbound/_seed.dart';
import '../adapters/outbound/shared_prefs_active_order_repository.dart';
import '../application/ports/outbound/active_order_repository_port.dart';
import '../application/use_cases/create_order.dart';
import '../application/use_cases/get_active_orders.dart';
import '../application/use_cases/get_order_by_id.dart';
import '../domain/active_order.dart';

/// Composition root for the orders feature.
final activeOrderRepositoryProvider = Provider<ActiveOrderRepositoryPort>(
  (ref) => SharedPrefsActiveOrderRepository(
    ref.watch(sharedPreferencesProvider),
    seedJson: kActiveOrdersSeedJson,
  ),
);

final getActiveOrdersUseCaseProvider = Provider<GetActiveOrdersUseCase>(
  (ref) => GetActiveOrdersUseCase(ref.watch(activeOrderRepositoryProvider)),
);

final getOrderByIdUseCaseProvider = Provider<GetOrderByIdUseCase>(
  (ref) => GetOrderByIdUseCase(ref.watch(activeOrderRepositoryProvider)),
);

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>(
  (ref) => CreateOrderUseCase(ref.watch(activeOrderRepositoryProvider)),
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
