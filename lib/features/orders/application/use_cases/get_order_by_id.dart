import '../../domain/active_order.dart';
import '../ports/outbound/active_order_repository_port.dart';

class GetOrderByIdInput {
  const GetOrderByIdInput({required this.id});
  final String id;
}

class GetOrderByIdUseCase {
  const GetOrderByIdUseCase(this._repository);
  final ActiveOrderRepositoryPort _repository;

  Future<ActiveOrder?> execute(GetOrderByIdInput input) =>
      _repository.findById(input.id);
}
