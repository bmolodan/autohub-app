import 'package:autohub/features/cars/application/ports/outbound/vehicle_repository_port.dart';
import 'package:autohub/features/cars/application/use_cases/add_vehicle.dart';
import 'package:autohub/features/cars/application/use_cases/get_vehicle.dart';
import 'package:autohub/features/cars/application/use_cases/list_vehicles.dart';
import 'package:autohub/features/cars/domain/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

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
      final useCase = AddVehicleUseCase(repo);

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
      final added = await AddVehicleUseCase(repo).execute(
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
        () => AddVehicleUseCase(repo).execute(const AddVehicleInput(
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
        () => AddVehicleUseCase(repo).execute(const AddVehicleInput(
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
      final added = await AddVehicleUseCase(repo).execute(
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
}
