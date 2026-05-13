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

  return ActiveOrder(
    id: m['id'] as String,
    title: m['title'] as String,
    status: _statusFromString(m['status'] as String),
    statusLabel: m['status_label'] as String,
    vehicleMake: vehicle['make'] as String,
    vehicleModel: vehicle['model'] as String,
    vehiclePlate: vehicle['plate'] as String,
    progress: (m['progress'] as num?)?.toDouble(),
    eta: _parseDate(m['eta']),
    scheduledFor: _parseDate(m['scheduled_for']),
    totalUah: (m['total_uah'] as num?)?.toInt(),
    timeline: timeline,
    photos: photos,
  );
}

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
      'status_label': o.statusLabel,
      'vehicle': {
        'make': o.vehicleMake,
        'model': o.vehicleModel,
        'plate': o.vehiclePlate,
      },
      'progress': o.progress,
      'eta': o.eta?.toIso8601String(),
      'scheduled_for': o.scheduledFor?.toIso8601String(),
      'total_uah': o.totalUah,
      'timeline': o.timeline.map(_timelineToJson).toList(),
      'photos': o.photos.map(_photoToJson).toList(),
    };

OrderTimelineEntry _timelineFromJson(Map<String, dynamic> m) =>
    OrderTimelineEntry(
      stage: _stageFromString(m['stage'] as String),
      label: m['label'] as String,
      at: DateTime.parse(m['at'] as String),
    );

Map<String, dynamic> _timelineToJson(OrderTimelineEntry e) => {
      'stage': _stageToString(e.stage),
      'label': e.label,
      'at': e.at.toIso8601String(),
    };

OrderStage _stageFromString(String raw) {
  switch (raw) {
    case 'pending_confirmation':
      return OrderStage.pendingConfirmation;
    case 'accepted':
      return OrderStage.accepted;
    case 'diagnostics':
      return OrderStage.diagnostics;
    case 'in_progress':
      return OrderStage.inProgress;
    case 'done':
      return OrderStage.done;
    case 'canceled':
      return OrderStage.canceled;
    default:
      throw FormatException('Unknown timeline stage: $raw');
  }
}

String _stageToString(OrderStage s) => switch (s) {
      OrderStage.pendingConfirmation => 'pending_confirmation',
      OrderStage.accepted => 'accepted',
      OrderStage.diagnostics => 'diagnostics',
      OrderStage.inProgress => 'in_progress',
      OrderStage.done => 'done',
      OrderStage.canceled => 'canceled',
    };

ActiveOrderStatus _statusFromString(String raw) {
  switch (raw) {
    case 'in_progress':
      return ActiveOrderStatus.inProgress;
    case 'pending_confirmation':
      return ActiveOrderStatus.pendingConfirmation;
    case 'canceled':
      return ActiveOrderStatus.canceled;
    default:
      throw FormatException('Unknown order status: $raw');
  }
}

String _statusToString(ActiveOrderStatus s) => switch (s) {
      ActiveOrderStatus.inProgress => 'in_progress',
      ActiveOrderStatus.pendingConfirmation => 'pending_confirmation',
      ActiveOrderStatus.canceled => 'canceled',
    };

DateTime? _parseDate(Object? raw) => raw is String ? DateTime.parse(raw) : null;
