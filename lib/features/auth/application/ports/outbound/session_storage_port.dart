import '../../../domain/session.dart';

/// Outbound port — persists the active session (secure storage, Hive, etc.).
abstract interface class SessionStoragePort {
  Future<Session?> read();
  Future<void> write(Session session);
  Future<void> clear();
}
