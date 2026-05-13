import '../../../../core/util/clock.dart';
import '../../../../core/util/id_generator.dart';
import '../../domain/vehicle.dart';
import '../ports/outbound/vehicle_repository_port.dart';

class AddVehicleInput {
  const AddVehicleInput({
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    this.vin,
    this.mileageKm = 0,
  });

  final String make;
  final String model;
  final int year;
  final String plate;
  final String? vin;
  final int mileageKm;
}

class AddVehicleUseCase {
  const AddVehicleUseCase(this._repository, this._clock, this._idGen);

  final VehicleRepositoryPort _repository;
  final Clock _clock;
  final IdGenerator _idGen;

  Future<Vehicle> execute(AddVehicleInput input) async {
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
    if (input.mileageKm < 0) {
      throw ArgumentError('mileageKm must be >= 0');
    }

    final vehicle = Vehicle(
      id: _idGen.next('v'),
      make: make,
      model: model,
      year: input.year,
      plate: plate,
      vin: (vin == null || vin.isEmpty) ? null : vin,
      mileageKm: input.mileageKm,
      nextServiceMileageKm: null,
    );

    await _repository.save(vehicle);
    return vehicle;
  }
}
