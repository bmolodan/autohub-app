import '../ports/outbound/vehicle_repository_port.dart';

class DeleteVehicleInput {
  const DeleteVehicleInput({required this.id});
  final String id;
}

class DeleteVehicleUseCase {
  const DeleteVehicleUseCase(this._repository);
  final VehicleRepositoryPort _repository;

  Future<void> execute(DeleteVehicleInput input) =>
      _repository.delete(input.id);
}
