# Features (use case map)

<!-- Generated: 2026-05-13 | 8 features | ~1100 tokens -->

No backend — "service layer" lives in `application/use_cases/`. Each entry below maps **inbound caller → use case → outbound port → adapter**.

## auth

```
PhoneScreen.submit    → RequestOtpUseCase.execute(phone)            → OtpGatewayPort.request           → FakeOtpGateway
OtpScreen.submit      → VerifyOtpUseCase.execute(challengeId,code)  → OtpGatewayPort.verify + SessionStoragePort.write → FakeOtpGateway + SharedPrefsSessionStorage
ProfileScreen.signOut → SignOutUseCase.execute()                    → SessionStoragePort.clear         → SharedPrefsSessionStorage
AuthController.build  → SessionStoragePort.read                                                        → SharedPrefsSessionStorage
```
Files: `lib/features/auth/{domain,application,adapters,composition,presentation}/`
Tests: `test/features/auth/`

## cars

```
CarsListScreen / Profile  → ListVehiclesUseCase.execute()        → VehicleRepositoryPort.findAll   → SharedPrefsVehicleRepository
CarDetailScreen           → GetVehicleUseCase.execute(id)        → VehicleRepositoryPort.findById  → SharedPrefsVehicleRepository
AddCarScreen.submit (new) → AddVehicleUseCase.execute(input)     → VehicleRepositoryPort.save      → SharedPrefsVehicleRepository
AddCarScreen.submit (edit)→ UpdateVehicleUseCase.execute(input)  → VehicleRepositoryPort.save      → SharedPrefsVehicleRepository
CarDetailScreen.delete    → DeleteVehicleUseCase.execute(id)     → VehicleRepositoryPort.delete    → SharedPrefsVehicleRepository
AddCarScreen make picker  → (catalog lookup)                     → CarCatalogPort.findMakes/models → AssetCarCatalogRepository (assets/data/car_makes.json)
```
Files: `lib/features/cars/...`
Tests: `test/features/cars/`
Seed: hardcoded Toyota Camry 2018 in `cars_providers.dart`. `AddCarScreen` accepts optional `?next=` query param: on save success it `context.go(next)` (used by the empty-vehicles booking detour from Home).

## orders

```
HomeScreen / OrderDetailScreen        → GetActiveOrdersUseCase.execute()         → ActiveOrderRepositoryPort.findAll
ProblemFormScreen.submit              → CreateOrderUseCase.execute(input)        → ActiveOrderRepositoryPort.save
HomeScreen card tap → OrderDetail     → GetOrderByIdUseCase.execute(id)          → ActiveOrderRepositoryPort.findById
OrderDetailScreen.cancel              → CancelOrderUseCase.execute(id)           → ActiveOrderRepositoryPort.save
(dev / internal)                      → UpdateOrderProgressUseCase.execute(...)  → ActiveOrderRepositoryPort.save
```
Adapter: `SharedPrefsActiveOrderRepository` (read+write, seeded from `_seed.dart`)
Codec: `active_order_codec.dart` (single source for asset + persistence formats)
Files: `lib/features/orders/...`
Tests: `test/features/orders/`

`CreateOrderUseCase` looks up service title/price from `booking/data/service_catalog.dart` (cross-feature dependency — flagged in flutter-review). Also accepts an optional `customTitle` from the booking flow when no catalog match exists.

## history

```
HistoryScreen → GetServiceHistoryUseCase.execute(vehicleId) → ServiceHistoryRepositoryPort.findByVehicle → MockServiceHistoryRepository (assets/mocks/service_history.json)
```
Read-only. Groups by year-month, sorts newest-first per month.
Tests: `test/features/history/`

## profile

```
ProfileScreen / Splash    → GetClientProfileUseCase.execute()             → ClientProfileRepositoryPort.find    → SharedPrefsClientProfileRepository
RegisterClientScreen.save → SaveClientProfileUseCase.execute(input)       → ClientProfileRepositoryPort.save    → SharedPrefsClientProfileRepository
AccountDeleteScreen.wipe  → WipeAccountUseCase.execute()                  → clears: session + vehicles + orders + profile keys
```
Files: `lib/features/profile/{domain,application,adapters,composition,presentation}/`
Codec: `client_profile_codec.dart`
Tests: `test/features/profile/`

Routes `/register` (first-time) and `/profile/edit` (returning) reuse the same `RegisterClientScreen` (toggled by `editMode` flag). The router's redirect bounces a user with a session but no saved profile to `/register` before allowing tab navigation.

## booking

```
HomeScreen "+ Записатись" → push /booking/service     → ServicePickerScreen (catalog lookup)
ServicePickerScreen "Далі"  → push /booking/problem?serviceId | ?customTitle  → ProblemFormScreen
ProblemFormScreen submit    → OrdersController.create (delegates into orders feature)
```
Data: `booking/data/service_catalog.dart` — const list of services.
No own domain/use-cases. Writes via the `orders` feature. When no preset service matches user need, the picker forwards a `customTitle` query param straight into `ProblemFormScreen`; `CreateOrder` uses it verbatim.

## home / profile-presentation / onboarding

Presentation-only consumers of `auth`, `cars`, `orders`, `profile` compositions. No own use cases.

- `HomeScreen` partitions orders by status: active list (in-progress + pending) on top, collapsible `Архів` ExpansionTile below for canceled ones.
- `HomeScreen` "+ Записатись" reads `vehiclesControllerProvider` synchronously; routes to `/cars/add?next=/booking/service` when the user has no vehicles, otherwise straight into the booking flow.

## Inbound-port pattern

Inbound ports are not declared as separate Dart abstractions in this project. Instead, **Riverpod Notifier methods** play that role (e.g. `OrdersController.create`, `VehiclesController.add/update/delete`, `AuthController.verifyCode`, `ClientProfileController.save`). The view depends on the controller; the controller composes the use case.

## Flow: book → see status

```
User taps "+ Записатись" on HomeScreen
  → (if no vehicles) AddCarScreen?next=/booking/service → save → /booking/service
  → ServicePickerScreen (picks "Заміна масла" or types a custom title)
  → ProblemFormScreen (description + photos)
  → OrdersController.create(serviceId | customTitle, description, vehicle)
       → CreateOrderUseCase.execute(...)
       → service_catalog.lookup (or use customTitle)
       → ActiveOrderRepositoryPort.save(order)
       → SharedPrefsActiveOrderRepository writes JSON to `active_orders` key
  → state = AsyncData([...existing, created])
  → context.go(/home) + push(/orders/<id>)
  → OrderDetailScreen reads orderByIdProvider(id)
       → GetOrderByIdUseCase.execute
       → port.findById
       → SharedPrefs reads JSON
  → renders pending hero + timeline (Hero animates the card → detail block shape)
```
