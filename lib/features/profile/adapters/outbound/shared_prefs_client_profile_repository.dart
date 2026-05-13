import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../application/ports/outbound/client_profile_repository_port.dart';
import '../../domain/client_profile.dart';

class SharedPrefsClientProfileRepository
    implements ClientProfileRepositoryPort {
  SharedPrefsClientProfileRepository(this._prefs);

  static const _key = 'client_profile';
  final SharedPreferences _prefs;

  @override
  Future<ClientProfile?> findByPhone(String phone) async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final stored = ClientProfile(
        phone: decoded['phone'] as String,
        name: decoded['name'] as String,
        email: decoded['email'] as String?,
      );
      return stored.phone == phone ? stored : null;
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(ClientProfile profile) async {
    final encoded = jsonEncode({
      'phone': profile.phone,
      'name': profile.name,
      'email': profile.email,
    });
    await _prefs.setString(_key, encoded);
  }
}
