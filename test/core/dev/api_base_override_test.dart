import 'package:autohub/core/dev/api_base_override.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('api base override', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('returns null when nothing is stored', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(loadApiBaseOverride(prefs), isNull);
    });

    test('returns the stored value', () async {
      SharedPreferences.setMockInitialValues({
        apiBaseOverrideKey: 'https://example.trycloudflare.com',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(
        loadApiBaseOverride(prefs),
        'https://example.trycloudflare.com',
      );
    });

    test('treats whitespace-only values as absent', () async {
      SharedPreferences.setMockInitialValues({apiBaseOverrideKey: '   '});
      final prefs = await SharedPreferences.getInstance();
      expect(loadApiBaseOverride(prefs), isNull);
    });

    test('save trims and persists', () async {
      final prefs = await SharedPreferences.getInstance();
      await saveApiBaseOverride(prefs, '  https://x.example  ');
      expect(prefs.getString(apiBaseOverrideKey), 'https://x.example');
    });

    test('save with null clears the key', () async {
      SharedPreferences.setMockInitialValues({
        apiBaseOverrideKey: 'https://x.example',
      });
      final prefs = await SharedPreferences.getInstance();
      await saveApiBaseOverride(prefs, null);
      expect(prefs.containsKey(apiBaseOverrideKey), isFalse);
    });

    test('save with empty string clears the key', () async {
      SharedPreferences.setMockInitialValues({
        apiBaseOverrideKey: 'https://x.example',
      });
      final prefs = await SharedPreferences.getInstance();
      await saveApiBaseOverride(prefs, '   ');
      expect(prefs.containsKey(apiBaseOverrideKey), isFalse);
    });
  });
}
