import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/shared_prefs_provider.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/id_generator.dart';
import '../adapters/outbound/shared_prefs_vehicle_repository.dart';
import '../application/ports/outbound/vehicle_repository_port.dart';
import '../application/use_cases/add_vehicle.dart';
import '../application/use_cases/get_vehicle.dart';
import '../application/use_cases/list_vehicles.dart';
import '../domain/vehicle.dart';

/// Composition root for the Cars feature.
///
/// Override [vehicleRepositoryProvider] to swap in an HTTP/Hive adapter —
/// use-cases and UI are unaffected.
final vehicleRepositoryProvider = Provider<VehicleRepositoryPort>(
  (ref) => SharedPrefsVehicleRepository(
    ref.watch(sharedPreferencesProvider),
    seed: const [
      Vehicle(
        id: 'v-camry-1',
        make: 'Toyota',
        model: 'Camry',
        year: 2018,
        plate: 'AA 1234 BC',
        vin: 'JT2BG28K3X0123456',
        mileageKm: 87500,
        nextServiceMileageKm: 90000,
      ),
    ],
  ),
);

final listVehiclesUseCaseProvider = Provider<ListVehiclesUseCase>(
  (ref) => ListVehiclesUseCase(ref.watch(vehicleRepositoryProvider)),
);

final getVehicleUseCaseProvider = Provider<GetVehicleUseCase>(
  (ref) => GetVehicleUseCase(ref.watch(vehicleRepositoryProvider)),
);

final addVehicleUseCaseProvider = Provider<AddVehicleUseCase>(
  (ref) => AddVehicleUseCase(
    ref.watch(vehicleRepositoryProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
  ),
);

/// View-model: list of vehicles. Notifier so screens can refresh on add.
class VehiclesController extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() {
    return ref.watch(listVehiclesUseCaseProvider).execute();
  }

  Future<Vehicle> add(AddVehicleInput input) async {
    final added = await ref.read(addVehicleUseCaseProvider).execute(input);
    state = AsyncData(await ref.read(listVehiclesUseCaseProvider).execute());
    return added;
  }
}

final vehiclesControllerProvider =
    AsyncNotifierProvider<VehiclesController, List<Vehicle>>(
  VehiclesController.new,
);

final vehicleByIdProvider =
    FutureProvider.family.autoDispose<Vehicle?, String>((ref, id) {
  return ref.watch(getVehicleUseCaseProvider).execute(GetVehicleInput(id: id));
});
