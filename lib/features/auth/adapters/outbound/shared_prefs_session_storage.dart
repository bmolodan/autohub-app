import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../application/ports/outbound/session_storage_port.dart';
import '../../domain/session.dart';

/// SharedPreferences-backed session storage.
///
/// Note: SharedPreferences is **not** encrypted. For real production with
/// access tokens, swap this for a `flutter_secure_storage` adapter — the
/// port stays the same.
class SharedPrefsSessionStorage implements SessionStoragePort {
  const SharedPrefsSessionStorage(this._prefs);

  static const _key = 'session';
  final SharedPreferences _prefs;

  @override
  Future<Session?> read() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return Session(
        phone: m['phone'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(Session session) async {
    final encoded = jsonEncode({
      'phone': session.phone,
      'createdAt': session.createdAt.toIso8601String(),
    });
    await _prefs.setString(_key, encoded);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
