import 'package:autohub/core/util/clock.dart';
import 'package:autohub/core/util/id_generator.dart';
import 'package:autohub/features/cars/application/ports/outbound/vehicle_repository_port.dart';
import 'package:autohub/features/cars/application/use_cases/add_vehicle.dart';
import 'package:autohub/features/cars/application/use_cases/delete_vehicle.dart';
import 'package:autohub/features/cars/application/use_cases/get_vehicle.dart';
import 'package:autohub/features/cars/application/use_cases/list_vehicles.dart';
import 'package:autohub/features/cars/application/use_cases/update_vehicle.dart';
import 'package:autohub/features/cars/domain/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

AddVehicleUseCase _addUseCase(VehicleRepositoryPort repo) => AddVehicleUseCase(
      repo,
      FixedClock(DateTime.utc(2026, 5, 13)),
      CountingIdGenerator(),
    );

/// In-memory fake port — independent of any real adapter so the use case
/// tests stay infrastructure-free.
class _FakeRepo implements VehicleRepositoryPort {
  final Map<String, Vehicle> _store = {};

  @override
  Future<List<Vehicle>> findAll() async => _store.values.toList();

  @override
  Future<Vehicle?> findById(String id) async => _store[id];

  @override
  Future<void> save(Vehicle vehicle) async {
    _store[vehicle.id] = vehicle;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}

Vehicle _v(String id, {String plate = 'AA1234BC'}) => Vehicle(
      id: id,
      make: 'Toyota',
      model: 'Camry',
      year: 2018,
      plate: plate,
      vin: null,
      mileageKm: 0,
      nextServiceMileageKm: null,
    );

void main() {
  group('ListVehiclesUseCase', () {
    test('returns empty when nothing saved', () async {
      final repo = _FakeRepo();
      final out = await ListVehiclesUseCase(repo).execute();
      expect(out, isEmpty);
    });

    test('returns previously saved vehicles', () async {
      final repo = _FakeRepo();
      await repo.save(_v('a'));
      await repo.save(_v('b'));

      final out = await ListVehiclesUseCase(repo).execute();
      expect(out.map((v) => v.id), containsAll(['a', 'b']));
    });
  });

  group('GetVehicleUseCase', () {
    test('returns saved vehicle by id', () async {
      final repo = _FakeRepo();
      await repo.save(_v('a'));

      final out =
          await GetVehicleUseCase(repo).execute(const GetVehicleInput(id: 'a'));
      expect(out, isNotNull);
      expect(out!.id, 'a');
    });

    test('returns null when id not found', () async {
      final repo = _FakeRepo();
      final out = await GetVehicleUseCase(repo)
          .execute(const GetVehicleInput(id: 'missing'));
      expect(out, isNull);
    });
  });

  group('AddVehicleUseCase', () {
    test('persists a new vehicle and assigns an id', () async {
      final repo = _FakeRepo();
      final useCase = _addUseCase(repo);

      final added = await useCase.execute(const AddVehicleInput(
        make: 'BMW',
        model: '320i',
        year: 2020,
        plate: 'BC4242XX',
        vin: 'WBA12345678901234',
      ));

      expect(added.id, isNotEmpty);
      expect(added.make, 'BMW');
      expect(added.model, '320i');
      expect(added.year, 2020);
      expect(added.plate, 'BC4242XX');
      expect(added.vin, 'WBA12345678901234');
      expect(added.mileageKm, 0);

      final fromRepo = await repo.findById(added.id);
      expect(fromRepo, isNotNull);
      expect(fromRepo!.plate, 'BC4242XX');
    });

    test('trims whitespace from string fields', () async {
      final repo = _FakeRepo();
      final added = await _addUseCase(repo).execute(
        const AddVehicleInput(
          make: '  Mazda  ',
          model: ' CX-5 ',
          year: 2017,
          plate: '  AA 0001 AA ',
          vin: ' SHORTVIN ',
        ),
      );
      expect(added.make, 'Mazda');
      expect(added.model, 'CX-5');
      expect(added.plate, 'AA 0001 AA');
      expect(added.vin, 'SHORTVIN');
    });

    test('rejects empty plate', () async {
      final repo = _FakeRepo();
      expect(
        () => _addUseCase(repo).execute(const AddVehicleInput(
          make: 'Mazda',
          model: 'CX-5',
          year: 2017,
          plate: '   ',
        )),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects implausible year', () async {
      final repo = _FakeRepo();
      expect(
        () => _addUseCase(repo).execute(const AddVehicleInput(
          make: 'Mazda',
          model: 'CX-5',
          year: 1800,
          plate: 'AA0001AA',
        )),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('treats null/empty vin as absent', () async {
      final repo = _FakeRepo();
      final added = await _addUseCase(repo).execute(
        const AddVehicleInput(
          make: 'Mazda',
          model: 'CX-5',
          year: 2017,
          plate: 'AA0001AA',
          vin: '   ',
        ),
      );
      expect(added.vin, isNull);
    });
  });

  group('UpdateVehicleUseCase', () {
    UpdateVehicleUseCase useCase(VehicleRepositoryPort repo) =>
        UpdateVehicleUseCase(repo, FixedClock(DateTime.utc(2026, 5, 13)));

    test('updates editable fields, preserves id and mileage', () async {
      final repo = _FakeRepo();
      final added = await _addUseCase(repo).execute(
        const AddVehicleInput(
          make: 'Toyota',
          model: 'Camry',
          year: 2018,
          plate: 'AA 1234 BB',
        ),
      );
      // Seed a mileage to verify it survives.
      await repo.save(Vehicle(
        id: added.id,
        make: added.make,
        model: added.model,
        year: added.year,
        plate: added.plate,
        vin: added.vin,
        mileageKm: 50000,
        nextServiceMileageKm: 60000,
      ));

      final updated = await useCase(repo).execute(UpdateVehicleInput(
        id: added.id,
        make: 'BMW',
        model: 'X5',
        year: 2020,
        plate: 'BB 4242 BB',
        vin: 'NEWVIN',
      ));

      expect(updated.id, added.id);
      expect(updated.make, 'BMW');
      expect(updated.model, 'X5');
      expect(updated.year, 2020);
      expect(updated.plate, 'BB 4242 BB');
      expect(updated.vin, 'NEWVIN');
      expect(updated.mileageKm, 50000);
      expect(updated.nextServiceMileageKm, 60000);
    });

    test('throws StateError for unknown id', () async {
      final repo = _FakeRepo();
      expect(
        () => useCase(repo).execute(const UpdateVehicleInput(
          id: 'nope',
          make: 'Toyota',
          model: 'Camry',
          year: 2018,
          plate: 'AA 1234 BB',
        )),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects implausible year', () async {
      final repo = _FakeRepo();
      final added = await _addUseCase(repo).execute(
        const AddVehicleInput(
          make: 'Toyota',
          model: 'Camry',
          year: 2018,
          plate: 'AA 1234 BB',
        ),
      );
      expect(
        () => useCase(repo).execute(UpdateVehicleInput(
          id: added.id,
          make: 'Toyota',
          model: 'Camry',
          year: 1800,
          plate: 'AA 1234 BB',
        )),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('DeleteVehicleUseCase', () {
    test('removes the vehicle', () async {
      final repo = _FakeRepo();
      final added = await _addUseCase(repo).execute(
        const AddVehicleInput(
          make: 'Toyota',
          model: 'Camry',
          year: 2018,
          plate: 'AA 1234 BB',
        ),
      );
      await DeleteVehicleUseCase(repo)
          .execute(DeleteVehicleInput(id: added.id));
      expect(await repo.findById(added.id), isNull);
      expect(await repo.findAll(), isEmpty);
    });

    test('no-op for unknown id (does not throw)', () async {
      final repo = _FakeRepo();
      await DeleteVehicleUseCase(repo)
          .execute(const DeleteVehicleInput(id: 'nope'));
      expect(await repo.findAll(), isEmpty);
    });
  });
}
