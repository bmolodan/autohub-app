import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../application/ports/outbound/active_order_repository_port.dart';
import '../../domain/active_order.dart';
import 'active_order_codec.dart';

/// Seeds [seedJson] only when the underlying key is absent — repeated cold
/// starts don't clobber user-saved orders. Seed write is fire-and-forget
/// because the constructor must stay sync.
class SharedPrefsActiveOrderRepository implements ActiveOrderRepositoryPort {
  SharedPrefsActiveOrderRepository(this._prefs, {String? seedJson}) {
    if (!_prefs.containsKey(_key) && seedJson != null) {
      try {
        unawaited(_writeAll(decodeActiveOrders(seedJson)));
      } on Object catch (_) {
        // Bad seed — leave storage empty.
      }
    }
  }

  static const _key = 'active_orders';
  final SharedPreferences _prefs;

  @override
  Future<List<ActiveOrder>> findAll() async => _readAll();

  @override
  Future<ActiveOrder?> findById(String id) async {
    for (final o in _readAll()) {
      if (o.id == id) return o;
    }
    return null;
  }

  @override
  Future<void> save(ActiveOrder order) async {
    final current = _readAll();
    final idx = current.indexWhere((o) => o.id == order.id);
    if (idx >= 0) {
      current[idx] = order;
    } else {
      current.add(order);
    }
    await _writeAll(current);
  }

  List<ActiveOrder> _readAll() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      return decodeActiveOrders(raw);
    } on Object catch (_) {
      return [];
    }
  }

  Future<void> _writeAll(List<ActiveOrder> orders) {
    return _prefs.setString(_key, encodeActiveOrders(orders));
  }
}
