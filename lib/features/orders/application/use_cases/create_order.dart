import '../../../../core/util/clock.dart';
import '../../../../core/util/id_generator.dart';
import '../../../cars/domain/vehicle.dart';
import '../../domain/active_order.dart';
import '../ports/outbound/active_order_repository_port.dart';

class CreateOrderInput {
  const CreateOrderInput({
    required this.title,
    required this.description,
    required this.vehicle,
    this.scheduledFor,
    this.photos = const [],
  });

  /// Placeholder title — the client-side app no longer picks a service
  /// from a catalog. The manager confirms / replaces this on the
  /// operator side. Caller passes a localized placeholder (e.g.
  /// "Запис на сервіс").
  final String title;

  /// Client's preferred date/time, or `null` for "nearest available
  /// slot" — the manager schedules in that case.
  final DateTime? scheduledFor;

  final String description;
  final Vehicle vehicle;
  final List<OrderPhoto> photos;
}

/// Creates a new booking. Status is always `pendingConfirmation` —
/// the STO confirms (or rejects) on their end before it moves to in-progress.
class CreateOrderUseCase {
  const CreateOrderUseCase(this._repository, this._clock, this._idGen);

  final ActiveOrderRepositoryPort _repository;
  final Clock _clock;
  final IdGenerator _idGen;

  Future<ActiveOrder> execute(CreateOrderInput input) async {
    final title = input.title.trim();
    if (title.isEmpty) throw ArgumentError('title is required');

    final now = _clock.now();
    final order = ActiveOrder(
      id: _idGen.next('o'),
      title: title,
      status: ActiveOrderStatus.pendingConfirmation,
      vehicleMake: input.vehicle.make,
      vehicleModel: input.vehicle.model,
      vehiclePlate: input.vehicle.plate,
      progress: null,
      eta: null,
      scheduledFor: input.scheduledFor,
      // Manager assigns services + price; client side stays unpriced.
      totalUah: null,
      timeline: [
        OrderTimelineEntry(
          stage: OrderStage.pendingConfirmation,
          at: now,
        ),
      ],
      photos: input.photos,
    );

    await _repository.save(order);
    return order;
  }
}
