import '../../../cars/domain/vehicle.dart';
import '../../domain/active_order.dart';
import '../ports/outbound/active_order_repository_port.dart';

class CreateOrderInput {
  const CreateOrderInput({
    required this.serviceTitle,
    required this.servicePriceUah,
    required this.description,
    required this.vehicle,
  });

  final String serviceTitle;
  final int servicePriceUah;
  final String description;
  final Vehicle vehicle;
}

/// Creates a new booking. Status is always `pendingConfirmation` —
/// the STO confirms (or rejects) on their end before it moves to in-progress.
class CreateOrderUseCase {
  const CreateOrderUseCase(this._repository);
  final ActiveOrderRepositoryPort _repository;

  Future<ActiveOrder> execute(CreateOrderInput input) async {
    final title = input.serviceTitle.trim();
    if (title.isEmpty) throw ArgumentError('serviceTitle is required');
    if (input.servicePriceUah < 0) {
      throw ArgumentError('servicePriceUah must be >= 0');
    }

    final now = DateTime.now();
    final order = ActiveOrder(
      id: 'o-${now.microsecondsSinceEpoch}',
      title: title,
      status: ActiveOrderStatus.pendingConfirmation,
      statusLabel: 'Очікує підтвердження',
      vehicleMake: input.vehicle.make,
      vehicleModel: input.vehicle.model,
      vehiclePlate: input.vehicle.plate,
      progress: null,
      eta: null,
      scheduledFor: null,
      totalUah: input.servicePriceUah,
      timeline: [
        OrderTimelineEntry(
          stage: OrderStage.pendingConfirmation,
          label: 'Очікує підтвердження',
          at: now,
        ),
      ],
    );

    await _repository.save(order);
    return order;
  }
}
