import '../ports/outbound/session_storage_port.dart';

class SignOutUseCase {
  const SignOutUseCase(this._storage);
  final SessionStoragePort _storage;

  Future<void> execute() => _storage.clear();
}
