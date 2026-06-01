import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../application/ports/outbound/session_storage_port.dart';
import '../../domain/session.dart';

/// Keychain (iOS) / EncryptedSharedPreferences (Android) backed session
/// storage. Holds the access + refresh tokens — must not be plain-text disk.
class SecureStorageSessionStorage implements SessionStoragePort {
  SecureStorageSessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'session_v1';
  final FlutterSecureStorage _storage;

  @override
  Future<Session?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return Session(
        phone: m['phone'] as String,
        accessToken: m['accessToken'] as String,
        refreshToken: m['refreshToken'] as String,
        accessExpiresAt: DateTime.parse(m['accessExpiresAt'] as String),
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
    } on Object catch (_) {
      // Corrupt payload — clear it so subsequent reads succeed.
      await _storage.delete(key: _key);
      return null;
    }
  }

  @override
  Future<void> write(Session session) async {
    final encoded = jsonEncode({
      'phone': session.phone,
      'accessToken': session.accessToken,
      'refreshToken': session.refreshToken,
      'accessExpiresAt': session.accessExpiresAt.toIso8601String(),
      'createdAt': session.createdAt.toIso8601String(),
    });
    await _storage.write(key: _key, value: encoded);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
