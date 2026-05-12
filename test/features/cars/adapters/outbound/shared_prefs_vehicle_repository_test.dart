import 'package:autohub/features/cars/adapters/outbound/shared_prefs_vehicle_repository.dart';
import 'package:autohub/features/cars/domain/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Vehicle _v(String id, {String make = 'Toyota'}) => Vehicle(
      id: id,
      make: make,
      model: 'Camry',
      year: 2018,
      plate: 'AA 1234 BC',
      vin: 'V$id',
      mileageKm: 87500,
      nextServiceMileageKm: 90000,
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPrefsVehicleRepository', () {
    test('findAll is empty on fresh prefs (no seed)', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsVehicleRepository(prefs);
      expect(await repo.findAll(), isEmpty);
    });

    test('save then findById round-trips all fields', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsVehicleRepository(prefs);

      await repo.save(_v('a'));
      final found = await repo.findById('a');

      expect(found, isNotNull);
      expect(found!.id, 'a');
      expect(found.make, 'Toyota');
      expect(found.year, 2018);
      expect(found.plate, 'AA 1234 BC');
      expect(found.vin, 'Va');
      expect(found.mileageKm, 87500);
      expect(found.nextServiceMileageKm, 90000);
    });

    test('save overwrites existing vehicle with same id', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsVehicleRepository(prefs);
      await repo.save(_v('a'));
      await repo.save(_v('a', make: 'BMW'));

      expect((await repo.findById('a'))!.make, 'BMW');
      expect(await repo.findAll(), hasLength(1));
    });

    test('seed populates on first read, only if storage is empty', () async {
      final prefs = await SharedPreferences.getInstance();
      final seed = [_v('seeded')];
      final repo = SharedPrefsVehicleRepository(prefs, seed: seed);

      expect((await repo.findAll()).single.id, 'seeded');
    });

    test('seed is NOT re-applied after a save (no duplicates on restart)',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final seed = [_v('seeded')];

      await SharedPrefsVehicleRepository(prefs, seed: seed).save(_v('added'));
      // New instance, same prefs — simulates app restart.
      final repo = SharedPrefsVehicleRepository(prefs, seed: seed);

      final all = await repo.findAll();
      expect(all.map((v) => v.id), containsAll(['seeded', 'added']));
      expect(all, hasLength(2));
    });

    test('survives a new instance (persistence across restart)', () async {
      final prefs1 = await SharedPreferences.getInstance();
      await SharedPrefsVehicleRepository(prefs1).save(_v('a'));

      final prefs2 = await SharedPreferences.getInstance();
      final repo = SharedPrefsVehicleRepository(prefs2);
      expect((await repo.findAll()).single.id, 'a');
    });

    test('findAll returns empty for corrupt storage', () async {
      SharedPreferences.setMockInitialValues({'vehicles': '[not json'});
      final prefs = await SharedPreferences.getInstance();
      expect(await SharedPrefsVehicleRepository(prefs).findAll(), isEmpty);
    });
  });
}
