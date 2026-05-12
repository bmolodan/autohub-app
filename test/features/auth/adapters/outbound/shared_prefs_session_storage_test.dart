import 'package:autohub/features/auth/adapters/outbound/shared_prefs_session_storage.dart';
import 'package:autohub/features/auth/domain/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPrefsSessionStorage', () {
    test('read returns null when no session has been written', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPrefsSessionStorage(prefs);
      expect(await storage.read(), isNull);
    });

    test('write then read returns the same session', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPrefsSessionStorage(prefs);
      final s = Session(
        phone: '+380671234567',
        createdAt: DateTime.utc(2026, 5, 12, 9, 30),
      );

      await storage.write(s);
      expect(await storage.read(), s);
    });

    test('clear removes the stored session', () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPrefsSessionStorage(prefs);

      await storage.write(
        Session(phone: '+380671234567', createdAt: DateTime.utc(2026, 5, 12)),
      );
      await storage.clear();
      expect(await storage.read(), isNull);
    });

    test('survives a new instance (i.e. simulated app restart)', () async {
      final s = Session(
        phone: '+380671234567',
        createdAt: DateTime.utc(2026, 5, 12),
      );

      final prefs1 = await SharedPreferences.getInstance();
      await SharedPrefsSessionStorage(prefs1).write(s);

      // Same backing prefs — simulates new adapter instance reading prior write.
      final prefs2 = await SharedPreferences.getInstance();
      final loaded = await SharedPrefsSessionStorage(prefs2).read();
      expect(loaded, s);
    });

    test('read returns null when stored value is corrupt', () async {
      SharedPreferences.setMockInitialValues({
        'session': '{not json',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPrefsSessionStorage(prefs);
      expect(await storage.read(), isNull);
    });
  });
}
