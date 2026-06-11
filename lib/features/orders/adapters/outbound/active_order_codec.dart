import 'dart:convert';

import '../../domain/active_order.dart';

/// JSON ↔ ActiveOrder. Used both for the seed fixture and for persistence
/// (SharedPreferences). One format, no drift between read-only and write paths.

List<ActiveOrder> decodeActiveOrders(String json) {
  final decoded = jsonDecode(json) as List<dynamic>;
  return decoded.cast<Map<String, dynamic>>().map(_orderFromJson).toList();
}

String encodeActiveOrders(List<ActiveOrder> orders) {
  return jsonEncode(orders.map(_orderToJson).toList());
}

/// Map form for HTTP adapters that need to encode/decode a single order.
ActiveOrder activeOrderFromMap(Map<String, dynamic> m) => _orderFromJson(m);

Map<String, dynamic> activeOrderToMap(ActiveOrder o) => _orderToJson(o);

ActiveOrder _orderFromJson(Map<String, dynamic> m) {
  final vehicle = m['vehicle'] as Map<String, dynamic>;
  final timeline = (m['timeline'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map(_timelineFromJson)
          .toList() ??
      const <OrderTimelineEntry>[];
  final photos = (m['photos'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map(_photoFromJson)
          .toList() ??
      const <OrderPhoto>[];
  final items = (m['items'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map(_itemFromJson)
          .toList() ??
      const <OrderItem>[];

  return ActiveOrder(
    id: m['id'] as String,
    title: m['title'] as String,
    status: _statusFromString(m['status'] as String),
    vehicleMake: vehicle['make'] as String,
    vehicleModel: vehicle['model'] as String,
    vehiclePlate: vehicle['plate'] as String,
    progress: (m['progress'] as num?)?.toDouble(),
    eta: _parseDate(m['eta']),
    scheduledFor: _parseDate(m['scheduled_for']),
    totalUah: (m['total_uah'] as num?)?.toInt(),
    paidUah: (m['paid_uah'] as num?)?.toInt(),
    discountUah: (m['discount_uah'] as num?)?.toInt(),
    number: m['number'] as String?,
    orderType: m['order_type'] as String?,
    resource: m['resource'] as String?,
    statusColor: m['status_color'] as String?,
    createdAt: _parseDate(m['created_at']),
    dueDate: _parseDate(m['due_date']),
    isUrgent: m['is_urgent'] as bool? ?? false,
    isOverdue: m['is_overdue'] as bool? ?? false,
    timeline: timeline,
    photos: photos,
    items: items,
  );
}

OrderItem _itemFromJson(Map<String, dynamic> m) => OrderItem(
      id: m['id'] as String,
      name: m['name'] as String,
      quantity: (m['quantity'] as num).toInt(),
      priceUah: (m['price_uah'] as num).toInt(),
      discountUah: (m['discount_uah'] as num?)?.toInt() ?? 0,
      sumUah: (m['sum_uah'] as num).toInt(),
      kind: _itemKindFromString(m['kind'] as String),
    );

Map<String, dynamic> _itemToJson(OrderItem i) => {
      'id': i.id,
      'name': i.name,
      'quantity': i.quantity,
      'price_uah': i.priceUah,
      'discount_uah': i.discountUah,
      'sum_uah': i.sumUah,
      'kind': _itemKindToString(i.kind),
    };

OrderItemKind _itemKindFromString(String raw) => switch (raw) {
      'service' => OrderItemKind.service,
      'product' => OrderItemKind.product,
      _ => OrderItemKind.service,
    };

String _itemKindToString(OrderItemKind k) => switch (k) {
      OrderItemKind.service => 'service',
      OrderItemKind.product => 'product',
    };

OrderPhoto _photoFromJson(Map<String, dynamic> m) => OrderPhoto(
      localPath: m['local_path'] as String,
      takenAt: DateTime.parse(m['taken_at'] as String),
    );

Map<String, dynamic> _photoToJson(OrderPhoto p) => {
      'local_path': p.localPath,
      'taken_at': p.takenAt.toIso8601String(),
    };

Map<String, dynamic> _orderToJson(ActiveOrder o) => {
      'id': o.id,
      'title': o.title,
      'status': _statusToString(o.status),
      'vehicle': {
        'make': o.vehicleMake,
        'model': o.vehicleModel,
        'plate': o.vehiclePlate,
      },
      'progress': o.progress,
      'eta': o.eta?.toIso8601String(),
      'scheduled_for': o.scheduledFor?.toIso8601String(),
      'total_uah': o.totalUah,
      'paid_uah': o.paidUah,
      'discount_uah': o.discountUah,
      'number': o.number,
      'order_type': o.orderType,
      'resource': o.resource,
      'status_color': o.statusColor,
      'created_at': o.createdAt?.toIso8601String(),
      'due_date': o.dueDate?.toIso8601String(),
      'is_urgent': o.isUrgent,
      'is_overdue': o.isOverdue,
      'timeline': o.timeline.map(_timelineToJson).toList(),
      'photos': o.photos.map(_photoToJson).toList(),
      'items': o.items.map(_itemToJson).toList(),
    };

OrderTimelineEntry _timelineFromJson(Map<String, dynamic> m) =>
    OrderTimelineEntry(
      stage: _stageFromString(m['stage'] as String),
      at: DateTime.parse(m['at'] as String),
    );

Map<String, dynamic> _timelineToJson(OrderTimelineEntry e) => {
      'stage': _stageToString(e.stage),
      'at': e.at.toIso8601String(),
    };

OrderStage _stageFromString(String raw) => switch (raw) {
      'pending_confirmation' => OrderStage.pendingConfirmation,
      'accepted' => OrderStage.accepted,
      'diagnostics' => OrderStage.diagnostics,
      'in_progress' => OrderStage.inProgress,
      'done' => OrderStage.done,
      'canceled' => OrderStage.canceled,
      _ => throw FormatException('Unknown timeline stage: $raw'),
    };

String _stageToString(OrderStage s) => switch (s) {
      OrderStage.pendingConfirmation => 'pending_confirmation',
      OrderStage.accepted => 'accepted',
      OrderStage.diagnostics => 'diagnostics',
      OrderStage.inProgress => 'in_progress',
      OrderStage.done => 'done',
      OrderStage.canceled => 'canceled',
    };

ActiveOrderStatus _statusFromString(String raw) => switch (raw) {
      'in_progress' => ActiveOrderStatus.inProgress,
      'pending_confirmation' => ActiveOrderStatus.pendingConfirmation,
      'canceled' => ActiveOrderStatus.canceled,
      _ => throw FormatException('Unknown order status: $raw'),
    };

String _statusToString(ActiveOrderStatus s) => switch (s) {
      ActiveOrderStatus.inProgress => 'in_progress',
      ActiveOrderStatus.pendingConfirmation => 'pending_confirmation',
      ActiveOrderStatus.canceled => 'canceled',
    };

DateTime? _parseDate(Object? raw) => raw is String ? DateTime.parse(raw) : null;
