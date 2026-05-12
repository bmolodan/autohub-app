# Data

<!-- Generated: 2026-05-13 | Files scanned: 8 adapters + 2 mock JSON | Token estimate: ~700 -->

No real backend yet. All persistence is **SharedPreferences** key-value (JSON-serialized) seeded from in-memory constants or asset JSON. Swappable behind hexagonal outbound ports.

## Storage map

| Port | Adapter (active) | Storage | Key | Seed source |
|---|---|---|---|---|
| `SessionStoragePort` (auth) | `SharedPrefsSessionStorage` | SharedPreferences | `session` | — (empty on first launch) |
| `VehicleRepositoryPort` (cars) | `SharedPrefsVehicleRepository` | SharedPreferences | `vehicles` | Hardcoded Toyota Camry in `cars_providers.dart` |
| `ActiveOrderRepositoryPort` (orders) | `SharedPrefsActiveOrderRepository` | SharedPreferences | `active_orders` | `lib/features/orders/adapters/outbound/_seed.dart` (Dart constant) |
| `ServiceHistoryRepositoryPort` (history) | `MockServiceHistoryRepository` | Asset (read-only) | n/a | `assets/mocks/service_history.json` |
| `OtpGatewayPort` (auth) | `FakeOtpGateway` | In-memory map | n/a | Accepts code `0000` for any phone |

## Domain entities

```
features/auth/domain/session.dart            Session(phone, createdAt)
features/cars/domain/vehicle.dart            Vehicle(id, make, model, year, plate, vin?, mileageKm, nextServiceMileageKm?)
features/history/domain/service_record.dart  ServiceRecord, ServiceHistoryMonth
features/orders/domain/active_order.dart     ActiveOrder, OrderTimelineEntry, OrderStage enum, ActiveOrderStatus enum
```

`ActiveOrder` is a tagged-union (`ActiveOrderStatus.{inProgress, pendingConfirmation}`) with optional fields per branch.

## Codec

`features/orders/adapters/outbound/active_order_codec.dart` — single JSON ↔ domain bridge used by both seed parse and SharedPrefs persist. Enums mapped explicitly (`in_progress`, `pending_confirmation`, etc.).

Cars + session adapters inline their own `_toJson/_fromJson` (codecs not yet extracted — minor inconsistency).

## Seed lifecycle

`SharedPrefsActiveOrderRepository` and `SharedPrefsVehicleRepository`:
- Constructor checks `!_prefs.containsKey(_key)`. If absent and seed provided → seed-write (fire-and-forget for orders; sync for cars).
- After first user write, the seed is **not** re-applied on subsequent restarts.

## Read/write contract

```dart
// Read-only
abstract interface class ServiceHistoryRepositoryPort {
  Future<List<ServiceRecord>> findByVehicle(String vehicleId);
}

// Read + write
abstract interface class VehicleRepositoryPort {
  Future<List<Vehicle>> findAll();
  Future<Vehicle?> findById(String id);
  Future<void> save(Vehicle vehicle);
}

abstract interface class ActiveOrderRepositoryPort {
  Future<List<ActiveOrder>> findAll();
  Future<ActiveOrder?> findById(String id);
  Future<void> save(ActiveOrder order);
}
```

## Known gaps

- `SharedPrefsVehicleRepository._writeAll` does **not** await `setString` → durability bug on rapid quit (fixed in orders, pending in cars).
- ID generation in `CreateOrderUseCase` uses `microsecondsSinceEpoch` — collision-possible on platforms with ms-quantized clocks.
- Seed JSON timestamps are fixed dates (2026-05-13); on long-running install the "У ремонті" card shows stale ETA.
