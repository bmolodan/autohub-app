import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_environment.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/shared_prefs_provider.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/id_generator.dart';
import '../adapters/outbound/asset_car_catalog.dart';
import '../adapters/outbound/http_vehicle_repository.dart';
import '../adapters/outbound/shared_prefs_vehicle_repository.dart';
import '../application/ports/outbound/car_catalog_port.dart';
import '../application/ports/outbound/vehicle_repository_port.dart';
import '../application/use_cases/add_vehicle.dart';
import '../application/use_cases/delete_vehicle.dart';
import '../application/use_cases/get_vehicle.dart';
import '../application/use_cases/list_vehicles.dart';
import '../application/use_cases/update_vehicle.dart';
import '../data/car_catalog.dart';
import '../domain/vehicle.dart';

/// Composition root for the Cars feature.
///
/// Override [vehicleRepositoryProvider] to swap in an HTTP/Hive adapter —
/// use-cases and UI are unaffected.
final vehicleRepositoryProvider = Provider<VehicleRepositoryPort>((ref) {
  return switch (ref.watch(appEnvironmentProvider)) {
    AppEnvironment.remote => HttpVehicleRepository(ref.watch(dioProvider)),
    AppEnvironment.local => SharedPrefsVehicleRepository(
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
  };
});

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

final updateVehicleUseCaseProvider = Provider<UpdateVehicleUseCase>(
  (ref) => UpdateVehicleUseCase(
    ref.watch(vehicleRepositoryProvider),
    ref.watch(clockProvider),
  ),
);

final deleteVehicleUseCaseProvider = Provider<DeleteVehicleUseCase>(
  (ref) => DeleteVehicleUseCase(ref.watch(vehicleRepositoryProvider)),
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

  Future<Vehicle> edit(UpdateVehicleInput input) async {
    final updated = await ref.read(updateVehicleUseCaseProvider).execute(input);
    state = AsyncData(await ref.read(listVehiclesUseCaseProvider).execute());
    ref.invalidate(vehicleByIdProvider(input.id));
    return updated;
  }

  Future<void> remove(String id) async {
    await ref.read(deleteVehicleUseCaseProvider).execute(
          DeleteVehicleInput(id: id),
        );
    state = AsyncData(await ref.read(listVehiclesUseCaseProvider).execute());
    ref.invalidate(vehicleByIdProvider(id));
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

/// Bundled make/model catalog used by the Add Car screen autocomplete.
final carCatalogPortProvider = Provider<CarCatalogPort>(
  (ref) => const AssetCarCatalog(),
);

final carCatalogProvider = FutureProvider<CarCatalog>(
  (ref) => ref.watch(carCatalogPortProvider).load(),
);
