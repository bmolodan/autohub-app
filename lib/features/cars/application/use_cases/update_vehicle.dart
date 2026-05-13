import '../../../../core/util/clock.dart';
import '../../domain/vehicle.dart';
import '../ports/outbound/vehicle_repository_port.dart';

class UpdateVehicleInput {
  const UpdateVehicleInput({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    this.vin,
    this.mileageKm,
  });

  final String id;
  final String make;
  final String model;
  final int year;
  final String plate;
  final String? vin;

  /// When non-null, overrides the existing mileage. Null keeps the
  /// stored value (useful when the edit form doesn't expose mileage).
  final int? mileageKm;
}

/// Updates a vehicle's editable fields. Preserves id and the
/// service-due field — those flow from history, not user input.
class UpdateVehicleUseCase {
  const UpdateVehicleUseCase(this._repository, this._clock);

  final VehicleRepositoryPort _repository;
  final Clock _clock;

  Future<Vehicle> execute(UpdateVehicleInput input) async {
    final existing = await _repository.findById(input.id);
    if (existing == null) {
      throw StateError('Vehicle ${input.id} not found');
    }

    final make = input.make.trim();
    final model = input.model.trim();
    final plate = input.plate.trim();
    final vin = input.vin?.trim();

    if (plate.isEmpty) throw ArgumentError('plate is required');
    if (make.isEmpty) throw ArgumentError('make is required');
    if (model.isEmpty) throw ArgumentError('model is required');
    if (input.year < 1900 || input.year > _clock.now().year + 1) {
      throw ArgumentError('year ${input.year} is implausible');
    }
    if (input.mileageKm != null && input.mileageKm! < 0) {
      throw ArgumentError('mileageKm must be >= 0');
    }

    final updated = Vehicle(
      id: existing.id,
      make: make,
      model: model,
      year: input.year,
      plate: plate,
      vin: (vin == null || vin.isEmpty) ? null : vin,
      mileageKm: input.mileageKm ?? existing.mileageKm,
      nextServiceMileageKm: existing.nextServiceMileageKm,
    );

    await _repository.save(updated);
    return updated;
  }
}
