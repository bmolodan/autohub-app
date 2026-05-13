import 'package:autohub/features/profile/adapters/outbound/shared_prefs_client_profile_repository.dart';
import 'package:autohub/features/profile/domain/client_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPrefsClientProfileRepository> _build({
  Map<String, Object> initial = const {},
}) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return SharedPrefsClientProfileRepository(prefs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPrefsClientProfileRepository', () {
    test('findByPhone returns null when nothing stored', () async {
      final repo = await _build();
      expect(await repo.findByPhone('+380671234567'), isNull);
    });

    test('save then findByPhone returns the saved profile', () async {
      final repo = await _build();
      await repo.save(const ClientProfile(
        phone: '+380671234567',
        name: 'Bohdan',
        email: 'bohdan@example.com',
      ));
      final loaded = await repo.findByPhone('+380671234567');
      expect(loaded?.name, 'Bohdan');
      expect(loaded?.email, 'bohdan@example.com');
    });

    test('round-trips a profile with null email', () async {
      final repo = await _build();
      await repo.save(const ClientProfile(
        phone: '+380671234567',
        name: 'Bohdan',
      ));
      final loaded = await repo.findByPhone('+380671234567');
      expect(loaded?.email, isNull);
    });

    test('findByPhone returns null and purges stale row on phone mismatch',
        () async {
      final repo = await _build();
      await repo.save(const ClientProfile(
        phone: '+380671234567',
        name: 'Bohdan',
      ));
      expect(await repo.findByPhone('+380999999999'), isNull);
      // After mismatch, even the original phone returns null because the
      // row is purged.
      expect(await repo.findByPhone('+380671234567'), isNull);
    });

    test('corrupt JSON returns null and purges the entry', () async {
      final repo = await _build(initial: {'client_profile': 'not-json'});
      expect(await repo.findByPhone('+380671234567'), isNull);
    });
  });
}
