import '../../domain/client_profile.dart';
import '../ports/outbound/client_profile_repository_port.dart';

class GetClientProfileUseCase {
  const GetClientProfileUseCase(this._repository);
  final ClientProfileRepositoryPort _repository;

  Future<ClientProfile?> execute(String phone) =>
      _repository.findByPhone(phone);
}
