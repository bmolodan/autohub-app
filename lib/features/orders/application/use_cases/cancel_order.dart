import '../../../../core/util/clock.dart';
import '../../domain/active_order.dart';
import '../ports/outbound/active_order_repository_port.dart';

class CancelOrderInput {
  const CancelOrderInput({required this.id});
  final String id;
}

class CancelOrderUseCase {
  const CancelOrderUseCase(this._repository, this._clock);
  final ActiveOrderRepositoryPort _repository;
  final Clock _clock;

  Future<ActiveOrder> execute(CancelOrderInput input) async {
    final existing = await _repository.findById(input.id);
    if (existing == null) {
      throw StateError('Order ${input.id} not found');
    }
    if (existing.status == ActiveOrderStatus.canceled) {
      throw StateError('Order ${input.id} already canceled');
    }

    final now = _clock.now();
    final canceled = ActiveOrder(
      id: existing.id,
      title: existing.title,
      status: ActiveOrderStatus.canceled,
      statusLabel: 'Скасовано',
      vehicleMake: existing.vehicleMake,
      vehicleModel: existing.vehicleModel,
      vehiclePlate: existing.vehiclePlate,
      progress: null,
      eta: existing.eta,
      scheduledFor: existing.scheduledFor,
      totalUah: existing.totalUah,
      timeline: [
        ...existing.timeline,
        OrderTimelineEntry(
          stage: OrderStage.canceled,
          label: 'Скасовано',
          at: now,
        ),
      ],
    );

    await _repository.save(canceled);
    return canceled;
  }
}
