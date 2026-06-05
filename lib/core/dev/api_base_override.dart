import 'package:shared_preferences/shared_preferences.dart';

const String apiBaseOverrideKey = 'dev.api_base_url';

String? loadApiBaseOverride(SharedPreferences prefs) {
  final raw = prefs.getString(apiBaseOverrideKey)?.trim();
  return (raw == null || raw.isEmpty) ? null : raw;
}

Future<void> saveApiBaseOverride(SharedPreferences prefs, String? url) {
  final trimmed = url?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return prefs.remove(apiBaseOverrideKey);
  }
  return prefs.setString(apiBaseOverrideKey, trimmed);
}
