# Data

<!-- Generated: 2026-05-13 | Files scanned: 10 adapters + 2 mock JSON + 1 catalog asset | Token estimate: ~800 -->

No real backend yet. All persistence is **SharedPreferences** key-value (JSON-serialized) seeded from in-memory constants or asset JSON. Swappable behind hexagonal outbound ports.

## Storage map

| Port | Adapter (active) | Storage | Key | Seed source |
|---|---|---|---|---|
| `SessionStoragePort` (auth) | `SharedPrefsSessionStorage` | SharedPreferences | `session` | — (empty on first launch) |
| `VehicleRepositoryPort` (cars) | `SharedPrefsVehicleRepository` | SharedPreferences | `vehicles` | Hardcoded Toyota Camry in `cars_providers.dart` |
| `CarCatalogPort` (cars) | `AssetCarCatalogRepository` | Asset (read-only) | n/a | `assets/data/car_makes.json` |
| `ActiveOrderRepositoryPort` (orders) | `SharedPrefsActiveOrderRepository` | SharedPreferences | `active_orders` | `lib/features/orders/adapters/outbound/_seed.dart` (Dart constant) |
| `ClientProfileRepositoryPort` (profile) | `SharedPrefsClientProfileRepository` | SharedPreferences | `client_profile` | — (empty on first launch — triggers `/register` redirect) |
| `ServiceHistoryRepositoryPort` (history) | `MockServiceHistoryRepository` | Asset (read-only) | n/a | `assets/mocks/service_history.json` |
| `OtpGatewayPort` (auth) | `FakeOtpGateway` | In-memory map | n/a | Accepts code `0000` for any phone |

## Domain entities

```
features/auth/domain/session.dart            Session(phone, createdAt)
features/cars/domain/vehicle.dart            Vehicle(id, make, model, year, plate, vin?, mileageKm, nextServiceMileageKm?)
features/history/domain/service_record.dart  ServiceRecord, ServiceHistoryMonth
features/orders/domain/active_order.dart     ActiveOrder, OrderTimelineEntry, OrderStage enum, ActiveOrderStatus enum
features/profile/domain/client_profile.dart  ClientProfile(name, phone, email?, createdAt)
```

`ActiveOrder` is a tagged-union (`ActiveOrderStatus.{inProgress, pendingConfirmation, canceled}`) with optional fields per branch.

## Codecs

Codec extraction (single file owning JSON ↔ domain) is used where the same shape is read from both seed JSON and SharedPreferences:

- `features/orders/adapters/outbound/active_order_codec.dart`
- `features/profile/adapters/outbound/client_profile_codec.dart`

Cars + session adapters inline their own `_toJson/_fromJson` (codecs not yet extracted — minor inconsistency).

## Seed lifecycle

`SharedPrefsActiveOrderRepository` and `SharedPrefsVehicleRepository`:
- Constructor checks `!_prefs.containsKey(_key)`. If absent and seed provided → seed-write.
- After first user write, the seed is **not** re-applied on subsequent restarts.

## Account wipe

`WipeAccountUseCase` (profile) is the inverse of seeding: it deletes every persisted key — `session`, `vehicles`, `active_orders`, `client_profile` — through `SharedPreferences.remove(key)`. Invoked from `/profile/account/delete` after a confirm dialog.

## Read/write contracts

```dart
// Read-only
abstract interface class ServiceHistoryRepositoryPort {
  Future<List<ServiceRecord>> findByVehicle(String vehicleId);
}

abstract interface class CarCatalogPort {
  Future<List<String>> findMakes();
  Future<List<String>> findModels(String make);
}

// Read + write
abstract interface class VehicleRepositoryPort {
  Future<List<Vehicle>> findAll();
  Future<Vehicle?> findById(String id);
  Future<void> save(Vehicle vehicle);
  Future<void> delete(String id);
}

abstract interface class ActiveOrderRepositoryPort {
  Future<List<ActiveOrder>> findAll();
  Future<ActiveOrder?> findById(String id);
  Future<void> save(ActiveOrder order);
}

abstract interface class ClientProfileRepositoryPort {
  Future<ClientProfile?> find();
  Future<void> save(ClientProfile profile);
  Future<void> clear();
}
```

## Known gaps

- ID generation uses `microsecondsSinceEpoch` — collision-possible on platforms with ms-quantized clocks.
- Seed JSON timestamps are fixed dates (2026-05-13); on long-running install the "У ремонті" card shows stale ETA.
- Real backend / HTTP adapters are not wired yet — `dio` and `core/network/dio_provider.dart` are present but unused by feature adapters.
