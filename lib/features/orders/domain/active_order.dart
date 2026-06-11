import 'order_item.dart';
import 'order_photo.dart';

export 'order_item.dart';
export 'order_photo.dart';

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
    required this.at,
  });

  final OrderStage stage;
  final DateTime at;

  @override
  bool operator ==(Object other) =>
      other is OrderTimelineEntry && other.stage == stage && other.at == at;

  @override
  int get hashCode => Object.hash(stage, at);
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
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.progress,
    required this.eta,
    required this.scheduledFor,
    required this.totalUah,
    this.paidUah,
    this.discountUah,
    this.number,
    this.orderType,
    this.resource,
    this.statusColor,
    this.createdAt,
    this.dueDate,
    this.isUrgent = false,
    this.isOverdue = false,
    this.timeline = const [],
    this.photos = const [],
    this.items = const [],
  });

  final String id;
  final String title;
  final ActiveOrderStatus status;
  final String vehicleMake;
  final String vehicleModel;
  final String vehiclePlate;

  /// 0.0–1.0, present when [status] is [ActiveOrderStatus.inProgress].
  final double? progress;
  final DateTime? eta;
  final DateTime? scheduledFor;
  final int? totalUah;
  final int? paidUah;
  final int? discountUah;
  final String? number;
  final String? orderType;
  final String? resource;
  final String? statusColor;
  final DateTime? createdAt;
  final DateTime? dueDate;
  final bool isUrgent;
  final bool isOverdue;
  final List<OrderTimelineEntry> timeline;
  final List<OrderPhoto> photos;
  final List<OrderItem> items;

  String get vehicleSummary => '$vehicleMake $vehicleModel · $vehiclePlate';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ActiveOrder) return false;
    if (timeline.length != other.timeline.length) return false;
    for (var i = 0; i < timeline.length; i++) {
      if (timeline[i] != other.timeline[i]) return false;
    }
    if (photos.length != other.photos.length) return false;
    for (var i = 0; i < photos.length; i++) {
      if (photos[i] != other.photos[i]) return false;
    }
    if (items.length != other.items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return id == other.id &&
        title == other.title &&
        status == other.status &&
        vehicleMake == other.vehicleMake &&
        vehicleModel == other.vehicleModel &&
        vehiclePlate == other.vehiclePlate &&
        progress == other.progress &&
        eta == other.eta &&
        scheduledFor == other.scheduledFor &&
        totalUah == other.totalUah &&
        paidUah == other.paidUah &&
        discountUah == other.discountUah &&
        number == other.number &&
        orderType == other.orderType &&
        resource == other.resource &&
        statusColor == other.statusColor &&
        createdAt == other.createdAt &&
        dueDate == other.dueDate &&
        isUrgent == other.isUrgent &&
        isOverdue == other.isOverdue;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        status,
        vehicleMake,
        vehicleModel,
        vehiclePlate,
        progress,
        eta,
        scheduledFor,
        totalUah,
        paidUah,
        discountUah,
        Object.hash(
          number,
          orderType,
          resource,
          statusColor,
          createdAt,
          dueDate,
          isUrgent,
          isOverdue,
        ),
        Object.hashAll(timeline),
        Object.hashAll(photos),
        Object.hashAll(items),
      );
}

enum ActiveOrderStatus { inProgress, pendingConfirmation, canceled }
