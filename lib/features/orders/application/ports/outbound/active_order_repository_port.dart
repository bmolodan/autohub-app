import '../../../domain/active_order.dart';

abstract interface class ActiveOrderRepositoryPort {
  Future<List<ActiveOrder>> findAll();
  Future<ActiveOrder?> findById(String id);
  Future<void> save(ActiveOrder order);

  /// Wipes ALL active orders for the current account. Used by the
  /// account-deletion flow.
  Future<void> clear();
}
