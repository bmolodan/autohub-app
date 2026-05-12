# Features (use case map)

<!-- Generated: 2026-05-13 | 7 features | ~900 tokens -->

No backend — "service layer" lives in `application/use_cases/`. Each entry below maps **inbound caller → use case → outbound port → adapter**.

## auth

```
PhoneScreen.submit    → RequestOtpUseCase.execute(phone)        → OtpGatewayPort.request           → FakeOtpGateway
OtpScreen.submit      → VerifyOtpUseCase.execute(challengeId,code) → OtpGatewayPort.verify + SessionStoragePort.write → FakeOtpGateway + SharedPrefsSessionStorage
ProfileScreen.signOut → SignOutUseCase.execute()                → SessionStoragePort.clear         → SharedPrefsSessionStorage
AuthController.build  → SessionStoragePort.read                                                    → SharedPrefsSessionStorage
```
Files: `lib/features/auth/{domain,application,adapters,composition,presentation}/`
Tests: `test/features/auth/` (15)

## cars

```
CarsListScreen / Profile  → ListVehiclesUseCase.execute()       → VehicleRepositoryPort.findAll    → SharedPrefsVehicleRepository
CarDetailScreen           → GetVehicleUseCase.execute(id)       → VehicleRepositoryPort.findById   → SharedPrefsVehicleRepository
AddCarScreen.submit       → AddVehicleUseCase.execute(input)    → VehicleRepositoryPort.save       → SharedPrefsVehicleRepository
```
Files: `lib/features/cars/...`
Tests: `test/features/cars/` (16)
Seed: hardcoded Toyota Camry 2018 in `cars_providers.dart`

## orders

```
HomeScreen / OrderDetailScreen      → GetActiveOrdersUseCase.execute()  → ActiveOrderRepositoryPort.findAll
ProblemFormScreen.submit            → CreateOrderUseCase.execute(input) → ActiveOrderRepositoryPort.save
HomeScreen card tap → OrderDetail   → GetOrderByIdUseCase.execute(id)   → ActiveOrderRepositoryPort.findById
```
Adapter: `SharedPrefsActiveOrderRepository` (read+write, seeded from `_seed.dart`)
Codec: `active_order_codec.dart` (single source for asset + persistence formats)
Files: `lib/features/orders/...`
Tests: `test/features/orders/` (21)

`CreateOrderUseCase` looks up service title/price from `booking/data/service_catalog.dart` ⚠ cross-feature dependency (flagged in flutter-review).

## history

```
HistoryScreen → GetServiceHistoryUseCase.execute(vehicleId) → ServiceHistoryRepositoryPort.findByVehicle → MockServiceHistoryRepository (assets/mocks/service_history.json)
```
Read-only. Groups by year-month, sorts newest-first per month.
Tests: `test/features/history/` (4)

## booking

```
HomeScreen "+ Записатись" → push /booking/service     → ServicePickerScreen (catalog lookup)
ServicePickerScreen "Далі"  → push /booking/problem?serviceId → ProblemFormScreen
ProblemFormScreen submit    → OrdersController.create (delegates into orders feature)
```
Data: `booking/data/service_catalog.dart` — const list of 5 services.
No own domain/use-cases. Writes via the `orders` feature.

## home / profile / onboarding

Presentation-only consumers of `auth`, `cars`, `orders` compositions. No own use cases.

## Test totals

```
auth/                       15
cars/                       16
orders/                     21
history/                     4
widget_test.dart             1
                          ───
                            57
```

## Inbound-port pattern

Inbound ports are not declared as separate Dart abstractions in this project. Instead, **Riverpod Notifier methods** play that role (e.g. `OrdersController.create`, `VehiclesController.add`, `AuthController.verifyCode`). The view depends on the controller; the controller composes the use case.

## Flow: book → see status

```
User taps "+ Записатись" on HomeScreen
  → ServicePickerScreen (picks "Заміна масла")
  → ProblemFormScreen (description + photos)
  → OrdersController.create(serviceId, description, vehicle)
       → CreateOrderUseCase.execute(...)
       → service_catalog.lookup
       → ActiveOrderRepositoryPort.save(order)
       → SharedPrefsActiveOrderRepository writes JSON to `active_orders` key
  → state = AsyncData([...existing, created])
  → context.go(/orders/<id>)
  → OrderDetailScreen reads orderByIdProvider(id)
       → GetOrderByIdUseCase.execute
       → port.findById
       → SharedPrefs reads JSON
  → renders pending hero + timeline
```
