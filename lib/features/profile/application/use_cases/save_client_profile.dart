import '../../domain/client_profile.dart';
import '../ports/outbound/client_profile_repository_port.dart';

class SaveClientProfileInput {
  const SaveClientProfileInput({
    required this.phone,
    required this.name,
    this.email,
  });

  final String phone;
  final String name;
  final String? email;
}

class SaveClientProfileUseCase {
  const SaveClientProfileUseCase(this._repository);
  final ClientProfileRepositoryPort _repository;

  Future<ClientProfile> execute(SaveClientProfileInput input) async {
    final name = input.name.trim();
    if (name.isEmpty) throw ArgumentError('name is required');
    if (input.phone.trim().isEmpty) throw ArgumentError('phone is required');

    final email = input.email?.trim();
    final cleanedEmail = (email == null || email.isEmpty) ? null : email;

    final profile = ClientProfile(
      phone: input.phone,
      name: name,
      email: cleanedEmail,
    );
    await _repository.save(profile);
    return profile;
  }
}
