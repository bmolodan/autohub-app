import '../../../../core/util/clock.dart';
import '../../domain/active_order.dart';
import '../ports/outbound/active_order_repository_port.dart';

class UpdateOrderProgressInput {
  const UpdateOrderProgressInput({
    required this.id,
    required this.progress,
    this.newStage,
    this.newStageLabel,
  });

  final String id;
  final double progress;
  final OrderStage? newStage;
  final String? newStageLabel;
}

class UpdateOrderProgressUseCase {
  const UpdateOrderProgressUseCase(this._repository, this._clock);
  final ActiveOrderRepositoryPort _repository;
  final Clock _clock;

  Future<ActiveOrder> execute(UpdateOrderProgressInput input) async {
    if (input.progress < 0 || input.progress > 1) {
      throw ArgumentError('progress must be in [0, 1], got ${input.progress}');
    }

    final existing = await _repository.findById(input.id);
    if (existing == null) {
      throw StateError('Order ${input.id} not found');
    }
    if (existing.status == ActiveOrderStatus.canceled) {
      throw StateError('Cannot update progress of canceled order ${input.id}');
    }

    final shouldAppendEntry =
        input.newStage != null && input.newStageLabel != null;

    final updated = ActiveOrder(
      id: existing.id,
      title: existing.title,
      status: existing.status,
      statusLabel: existing.statusLabel,
      vehicleMake: existing.vehicleMake,
      vehicleModel: existing.vehicleModel,
      vehiclePlate: existing.vehiclePlate,
      progress: input.progress,
      eta: existing.eta,
      scheduledFor: existing.scheduledFor,
      totalUah: existing.totalUah,
      timeline: shouldAppendEntry
          ? [
              ...existing.timeline,
              OrderTimelineEntry(
                stage: input.newStage!,
                label: input.newStageLabel!,
                at: _clock.now(),
              ),
            ]
          : existing.timeline,
    );

    await _repository.save(updated);
    return updated;
  }
}
