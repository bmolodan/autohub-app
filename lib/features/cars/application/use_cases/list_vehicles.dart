import '../../domain/vehicle.dart';
import '../ports/outbound/vehicle_repository_port.dart';

class ListVehiclesUseCase {
  const ListVehiclesUseCase(this._repository);

  final VehicleRepositoryPort _repository;

  Future<List<Vehicle>> execute() => _repository.findAll();
}
