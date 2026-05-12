import '../../domain/active_order.dart';
import '../ports/outbound/active_order_repository_port.dart';

class GetActiveOrdersUseCase {
  const GetActiveOrdersUseCase(this._repository);

  final ActiveOrderRepositoryPort _repository;

  Future<List<ActiveOrder>> execute() => _repository.findAll();
}
