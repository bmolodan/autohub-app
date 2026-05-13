import 'package:shared_preferences/shared_preferences.dart';

import '../../application/ports/outbound/client_profile_repository_port.dart';
import '../../domain/client_profile.dart';
import 'client_profile_codec.dart';

class SharedPrefsClientProfileRepository
    implements ClientProfileRepositoryPort {
  SharedPrefsClientProfileRepository(this._prefs);

  static const _key = 'client_profile';
  final SharedPreferences _prefs;

  @override
  Future<ClientProfile?> findByPhone(String phone) async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    final stored = tryDecodeClientProfile(raw);
    if (stored == null) {
      // Corrupt entry — purge so subsequent reads start clean.
      await _prefs.remove(_key);
      return null;
    }
    if (stored.phone == phone) return stored;
    // Different user signed in — drop the stale row so PII for the
    // previous user doesn't linger in plaintext storage.
    await _prefs.remove(_key);
    return null;
  }

  @override
  Future<void> save(ClientProfile profile) async {
    await _prefs.setString(_key, encodeClientProfile(profile));
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
