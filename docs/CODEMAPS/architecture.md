# Flutter App Architecture Codemap

**Last Updated:** 2026-06-11  
**Framework:** Flutter 3.22+, Dart 3.4+  
**State/DI:** Riverpod 3.3.1  
**Navigation:** go_router 17.2.3

## Hexagonal Architecture per Feature

Each feature (`lib/features/<name>/`) follows domain-driven design:

```
feature/
├── domain/                     ← Pure Dart entities, no infra imports
│   ├── entity.dart               (e.g., ActiveOrder, Vehicle, Session)
│   └── value_objects.dart        (e.g., OtpChallenge, OtpRequestFailure)
├── application/                ← Business logic + ports (abstractions)
│   ├── ports/
│   │   └── outbound/             (e.g., OtpGatewayPort, VehicleRepositoryPort)
│   ├── use_cases/                (e.g., RequestOtpUseCase, CreateBookingUseCase)
│   └── controllers/              (Riverpod AsyncNotifier for state)
├── adapters/                   ← Infrastructure implementations
│   ├── inbound/                  (ConsumerWidget screens)
│   │   └── *_screen.dart         (UI, binds use cases → Riverpod)
│   └── outbound/                 (Port implementations)
│       ├── http_*_*.dart         (Real HTTP to middleware)
│       ├── fake_*_*.dart         (In-memory fakes for testing)
│       ├── shared_prefs_*.dart   (Local persistence)
│       ├── *_codec.dart          (JSON ↔ Dart serialization)
│       └── _seed.dart            (Fixture data)
└── composition/                ← Riverpod provider wiring
    └── *_provider.dart           (Port → UseCase → Controller binding)
```

**Dependency Direction:** Adapters → Application → Domain  
Domain imports nothing from infra; all infrastructure imports Domain.

## Core Features

| Feature | Entry | Ports | Controllers | UI Screens |
|---------|-------|-------|-------------|-----------|
| **auth** | `OtpRequestScreen` | OtpGatewayPort, SessionStoragePort | AuthController | OtpRequestScreen, OtpVerifyScreen |
| **cars** | `CarsListScreen` | VehicleRepositoryPort | VehiclesController | CarsListScreen, CarDetailScreen, AddCarScreen |
| **booking** | `BookingScreen` | ActiveOrderRepositoryPort | OrdersController | BookingScreen, BookingConfirmScreen |
| **orders** | `OrdersListScreen` | ActiveOrderRepositoryPort, PhotoStoragePort | OrdersController | OrdersListScreen, OrderDetailScreen |
| **history** | `HistoryScreen` | ServiceHistoryRepositoryPort | HistoryController | HistoryScreen |
| **profile** | `ProfileScreen` | ProfileRepositoryPort | ProfileController | ProfileScreen |
| **home** | `HomePage` | — | — | HomePage (tab nav hub) |
| **onboarding** | `OnboardingScreen` | — | — | OnboardingScreen (walkthrough) |

## Request Flow: OTP Verification

```
1. User types phone → OtpRequestScreen
2. requestOtpUseCase.call(phone)
   ├─ calls otpGatewayPort.request(phone)
   │  └─ HTTP POST /v1/auth/otp/request (HttpOtpGateway)
   │     └─ Response: { challengeId }
   └─ Stores challengeId locally
3. AuthController notifies: UI shows OTP verify screen
4. User enters 6-digit code → OtpVerifyScreen
5. verifyOtpUseCase.call(challengeId, code)
   ├─ calls otpGatewayPort.verify(challengeId, code)
   │  └─ HTTP POST /v1/auth/otp/verify (HttpOtpGateway)
   │     └─ Response: { accessToken, refreshToken, profile }
   └─ Stores tokens + profile in secure storage
6. AuthController notifies: go_router redirects to /home
```

## Dependency Injection (Riverpod)

All providers live in `composition/` → wired at app root.

Example:
```dart
// composition/otp_gateway_provider.dart
final otpGatewayProvider = Provider<OtpGatewayPort>((ref) {
  final dio = ref.watch(dioProvider);
  return HttpOtpGateway(dio);
});

final requestOtpUseCaseProvider = Provider((ref) {
  final port = ref.watch(otpGatewayProvider);
  return RequestOtpUseCase(port);
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(requestOtpUseCaseProvider));
});
```

## State Management

**Write flows:** One controller per feature (`AuthController`, `VehiclesController`, etc.)
- Type: `AsyncNotifierProvider<Controller, AsyncValue<State>>`
- Handles state + side effects (navigation, toast)
- Optimistic updates: `state = AsyncData([...previousList, newItem])`

**Read flows:** Plain `FutureProvider` or `FutureProvider.family`
- Detail screens use `.family.autoDispose` (keyed by ID, auto-cleanup)
- Lists use `.autoDispose` (auto-cleanup when widget unmounts)

**Example: Cars List**
```dart
// domain/vehicle.dart
class Vehicle {
  final String id, make, model;
  final int year;
  // ...
}

// application/ports/outbound/vehicle_repository_port.dart
abstract class VehicleRepositoryPort {
  Future<List<Vehicle>> findAll();
  Future<void> save(Vehicle v);
  // ...
}

// adapters/outbound/http_vehicle_repository.dart
class HttpVehicleRepository implements VehicleRepositoryPort {
  // Calls /vehicles, parses via vehicleFromMap codec
}

// adapters/inbound/cars_list_screen.dart
class CarsListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cars = ref.watch(vehiclesProvider);
    return cars.when(
      data: (list) => ListView(children: [...]),
      loading: () => Skeleton(),
      error: (e, st) => ErrorWidget(),
    );
  }
}
```

## Environment & Configuration

**Build-time environment:** `APP_ENV` + `API_URL` (via --dart-define)

- `APP_ENV=remote` (default) → HTTP adapters
- `APP_ENV=local` → SharedPrefs + Fake adapters

**Runtime overrides:** SharedPrefs `dev.api_base_url`
- Via Profile → "Сервер API" → paste URL → hot-restart
- Resets on app kill; use "Скинути" to revert to build-time default

**See:** `lib/core/config/app_environment.dart`

## Router

**File:** `lib/core/router/app_router.dart`

**Structure:**
```dart
GoRouter(
  routes: [
    GoRoute(path: '/onboarding', builder: OnboardingScreen()),
    ShellRoute(
      builder: HomePage(),  // tab nav
      routes: [
        GoRoute(path: '/home/cars', builder: CarsListScreen()),
        GoRoute(path: '/home/orders', builder: OrdersListScreen()),
        // ...
      ],
    ),
    GoRoute(path: '/car/add', builder: AddCarScreen()),  // full-screen
    GoRoute(path: '/car/:id', builder: CarDetailScreen()),
    GoRoute(path: '/booking', builder: BookingScreen()),
    GoRoute(path: '/booking/confirm', builder: BookingConfirmScreen()),
    // ...
  ],
  redirect: (context, state) {
    // Auth check: if no session + not in _publicRoutes → /onboarding
  },
);
```

**Public routes:** `/onboarding`, `/auth/otp/*`  
**Auth-gated:** Everything else requires valid JWT in session storage

## Core Utilities & Theme

| Directory | Purpose |
|-----------|---------|
| `core/config/` | `app_environment.dart`, `app_defaults.dart` |
| `core/network/` | `dio_provider.dart` (HTTP client setup) |
| `core/storage/` | `session_storage.dart`, `shared_preferences_wrapper.dart` |
| `core/router/` | `app_router.dart`, navigation guards |
| `core/theme/` | `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_radii.dart` |
| `core/util/` | `date_format.dart` (formatHm, formatDdMmHm), `jwt_payload.dart`, misc helpers |
| `core/widgets/` | Reusable widgets (buttons, input fields, dialogs, skeletons) |
| `core/dev/` | Dev overrides (API URL editor, test helpers) |
| `core/telemetry/` | Sentry setup (no-op if `SENTRY_DSN` unset) |

## Test Architecture

**TDD discipline:** Write failing tests before code (compile-time RED counts)

**Test structure mirrors lib/:**
```
test/features/<feature>/
├── domain/
├── application/
│   └── use_cases/
│       └── <use_case>_test.dart    (inject FakePort)
└── adapters/
    └── outbound/
        └── <adapter>_test.dart     (mock SharedPrefs / Dio)
```

**Use-case tests:**
```dart
test('RequestOtpUseCase calls port and updates state', () async {
  final port = _FakeOtpGateway();
  final useCase = RequestOtpUseCase(port);
  final result = await useCase.call('380501234567');
  expect(result.ok, true);
  expect(result.challengeId, '...');
});

class _FakeOtpGateway implements OtpGatewayPort {
  @override
  Future<OtpChallenge> request(String phone) async {
    return OtpChallenge(id: 'test-id', phone: phone);
  }
  // ...
}
```

**Adapter tests:**
```dart
test('HttpVehicleRepository.findAll parses response', () async {
  final dio = MockDio();
  dio.get.expect(...).reply(200, [vehicleJson]);
  
  final repo = HttpVehicleRepository(dio);
  final vehicles = await repo.findAll();
  
  expect(vehicles.length, 1);
  expect(vehicles[0].make, 'Toyota');
});
```

**Widget tests:**
```dart
testWidgets('OtpRequestScreen submits phone', (tester) async {
  final container = ProviderContainer(
    overrides: [
      appEnvironmentProvider.overrideWithValue(AppEnvironment.local),
    ],
  );
  
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: App()),
  );
  
  await tester.enterText(find.byType(TextField), '0501234567');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
  
  expect(find.byType(OtpVerifyScreen), findsOneWidget);
});
```

## Patterns & Conventions

**Immutability:** All domain entities use `final` fields.  
**Sealed by status:** Nullable optional fields (e.g., `ActiveOrder.canceledAt` is null until canceled).  
**Codec extraction:** Shared JSON shape (seed + persistence) → dedicated `*_codec.dart`.  
**Mounted checks:** After every `await`, guard `context.*` calls with `if (!context.mounted) return;`.  
**Theme tokens:** Never raw numbers/strings; always use `AppSpacing.*`, `AppColors.*`, etc.  
**Hardcoded strings:** Ukrainian UI; English code/comments.  
**Dates:** ISO 8601 on wire; format with `formatHm()` / `formatDdMmHm()` in widgets.

## Current Status

**57/57 tests passing**  
**All HTTP adapters active** (HttpOtpGateway, HttpVehicleRepository, HttpActiveOrderRepository, HttpServiceHistoryRepository)  
**Default to remote** (talks to `https://autohub.bmolodan.dev/v1`)  
**AppEnvironment override available** (for local widget tests)
