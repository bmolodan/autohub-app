import '../../domain/vehicle.dart';
import '../ports/outbound/vehicle_repository_port.dart';

class GetVehicleInput {
  const GetVehicleInput({required this.id});
  final String id;
}

class GetVehicleUseCase {
  const GetVehicleUseCase(this._repository);

  final VehicleRepositoryPort _repository;

  Future<Vehicle?> execute(GetVehicleInput input) =>
      _repository.findById(input.id);
}
