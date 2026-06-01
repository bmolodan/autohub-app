import 'package:autohub/features/auth/application/ports/outbound/session_storage_port.dart';
import 'package:autohub/features/auth/domain/session.dart';

/// In-memory `SessionStoragePort` for tests — replaces both
/// SharedPreferences and flutter_secure_storage backends so widget and
/// use-case tests do not touch native channels.
class InMemorySessionStorage implements SessionStoragePort {
  InMemorySessionStorage([Session? initial]) : _session = initial;
  Session? _session;

  @override
  Future<Session?> read() async => _session;

  @override
  Future<void> write(Session session) async => _session = session;

  @override
  Future<void> clear() async => _session = null;
}

/// Convenience factory for tests that just need a non-empty session.
Session testSession({
  String phone = '+380671234567',
  String accessToken = 'fake-access',
  String refreshToken = 'fake-refresh',
  DateTime? accessExpiresAt,
  DateTime? createdAt,
}) {
  final now = createdAt ?? DateTime.utc(2026, 5, 13);
  return Session(
    phone: phone,
    accessToken: accessToken,
    refreshToken: refreshToken,
    accessExpiresAt: accessExpiresAt ?? now.add(const Duration(minutes: 15)),
    createdAt: now,
  );
}
