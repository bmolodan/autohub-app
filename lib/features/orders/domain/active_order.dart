enum OrderStage {
  pendingConfirmation,
  accepted,
  diagnostics,
  inProgress,
  done,
  canceled,
}

class OrderTimelineEntry {
  const OrderTimelineEntry({
    required this.stage,
    required this.label,
    required this.at,
  });

  final OrderStage stage;
  final String label;
  final DateTime at;

  @override
  bool operator ==(Object other) =>
      other is OrderTimelineEntry &&
      other.stage == stage &&
      other.label == label &&
      other.at == at;

  @override
  int get hashCode => Object.hash(stage, label, at);
}

/// Active work-order shown on the Home screen.
///
/// Three shapes share the same class:
///   - [ActiveOrderStatus.inProgress] — has [progress] and [eta]
///   - [ActiveOrderStatus.pendingConfirmation] — has [scheduledFor]
///   - [ActiveOrderStatus.canceled] — terminal; cancellation timestamp lives
///     as the last [OrderTimelineEntry].
class ActiveOrder {
  const ActiveOrder({
    required this.id,
    required this.title,
    required this.status,
    required this.statusLabel,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.progress,
    required this.eta,
    required this.scheduledFor,
    required this.totalUah,
    this.timeline = const [],
  });

  final String id;
  final String title;
  final ActiveOrderStatus status;
  final String statusLabel;
  final String vehicleMake;
  final String vehicleModel;
  final String vehiclePlate;

  /// 0.0–1.0, present when [status] is [ActiveOrderStatus.inProgress].
  final double? progress;
  final DateTime? eta;
  final DateTime? scheduledFor;
  final int? totalUah;
  final List<OrderTimelineEntry> timeline;

  String get vehicleSummary => '$vehicleMake $vehicleModel · $vehiclePlate';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ActiveOrder) return false;
    if (timeline.length != other.timeline.length) return false;
    for (var i = 0; i < timeline.length; i++) {
      if (timeline[i] != other.timeline[i]) return false;
    }
    return id == other.id &&
        title == other.title &&
        status == other.status &&
        statusLabel == other.statusLabel &&
        vehicleMake == other.vehicleMake &&
        vehicleModel == other.vehicleModel &&
        vehiclePlate == other.vehiclePlate &&
        progress == other.progress &&
        eta == other.eta &&
        scheduledFor == other.scheduledFor &&
        totalUah == other.totalUah;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        status,
        statusLabel,
        vehicleMake,
        vehicleModel,
        vehiclePlate,
        progress,
        eta,
        scheduledFor,
        totalUah,
        Object.hashAll(timeline),
      );
}

enum ActiveOrderStatus { inProgress, pendingConfirmation, canceled }
