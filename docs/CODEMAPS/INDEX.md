# Flutter App Codemaps Index

**Last Updated:** 2026-06-11  
**Entry Point:** `lib/main.dart`  
**Test Status:** 57/57 passing

## Quick Links

| Document | Covers |
|----------|--------|
| **[architecture.md](./architecture.md)** | Hexagonal per-feature layout, Riverpod wiring, state management, router setup |
| **[frontend.md](./frontend.md)** | HTTP adapters (OTP, Vehicles, Orders, History), error handling, codecs, theme |
| **[data.md](./data.md)** | Secure session storage, SharedPrefs persistence, JSON codecs, domain entities |
| **[dependencies.md](./dependencies.md)** | pubspec.yaml breakdown, Riverpod patterns, environment config, testing strategy |

## Directory Structure

```
lib/
├── main.dart                    ← entry point (bootstrap, error handling, Riverpod scope)
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── session.dart      JWT + phone
│   │   │   └── value_objects.dart OtpChallenge, OtpRequestFailure
│   │   ├── application/
│   │   │   ├── ports/outbound/
│   │   │   │   ├── otp_gateway_port.dart      request(phone) + verify(id, code)
│   │   │   │   └── session_storage_port.dart  read() + write()
│   │   │   └── use_cases/
│   │   │       ├── request_otp_use_case.dart
│   │   │       └── verify_otp_use_case.dart
│   │   ├── adapters/
│   │   │   ├── inbound/
│   │   │   │   ├── otp_request_screen.dart    Phone input
│   │   │   │   └── otp_verify_screen.dart     6-digit code (ClipRect hidden)
│   │   │   └── outbound/
│   │   │       ├── http_otp_gateway.dart      HTTP POST /auth/otp/*
│   │   │       ├── fake_otp_gateway.dart      Accepts "0000"
│   │   │       ├── secure_storage_session_storage.dart
│   │   │       └── otp_codec.dart             JSON ↔ Dart
│   │   └── composition/
│   │       └── auth_provider.dart             Port → UseCase → Controller
│   │
│   ├── cars/
│   │   ├── domain/vehicle.dart                 Vehicle entity
│   │   ├── application/
│   │   │   ├── ports/outbound/
│   │   │   │   ├── vehicle_repository_port.dart  CRUD operations
│   │   │   │   └── car_catalog_port.dart         Make/model picker
│   │   │   └── use_cases/
│   │   │       ├── list_vehicles_use_case.dart
│   │   │       └── create_vehicle_use_case.dart
│   │   ├── adapters/
│   │   │   ├── inbound/
│   │   │   │   ├── cars_list_screen.dart
│   │   │   │   ├── car_detail_screen.dart
│   │   │   │   └── add_car_screen.dart
│   │   │   └── outbound/
│   │   │       ├── http_vehicle_repository.dart  GET/POST /vehicles (read-only)
│   │   │       ├── fake_vehicle_repository.dart
│   │   │       └── vehicle_codec.dart
│   │   └── composition/
│   │       └── vehicle_provider.dart
│   │
│   ├── orders/
│   │   ├── domain/active_order.dart            Status enum + optional fields
│   │   ├── application/
│   │   │   ├── ports/outbound/
│   │   │   │   ├── active_order_repository_port.dart   findAll, findById, save, cancel
│   │   │   │   └── photo_storage_port.dart             upload(blob) → URL
│   │   │   └── use_cases/
│   │   │       ├── create_order_use_case.dart
│   │   │       └── get_active_orders_use_case.dart
│   │   ├── adapters/
│   │   │   ├── inbound/
│   │   │   │   ├── orders_list_screen.dart
│   │   │   │   └── order_detail_screen.dart
│   │   │   └── outbound/
│   │   │       ├── http_active_order_repository.dart  GET /orders, POST /orders
│   │   │       ├── image_picker_photo_storage.dart     Upload via /photos
│   │   │       └── active_order_codec.dart
│   │   └── composition/
│   │       └── orders_provider.dart
│   │
│   ├── history/
│   │   ├── domain/service_record.dart          Past service entries
│   │   ├── application/
│   │   │   ├── ports/outbound/
│   │   │   │   └── service_history_repository_port.dart
│   │   │   └── use_cases/
│   │   │       └── get_service_history_use_case.dart
│   │   ├── adapters/
│   │   │   ├── inbound/
│   │   │   │   └── history_screen.dart
│   │   │   └── outbound/
│   │   │       └── http_service_history_repository.dart  GET /history
│   │   └── composition/
│   │       └── history_provider.dart
│   │
│   ├── profile/
│   │   ├── domain/client_profile.dart          Name + phone + email
│   │   ├── application/
│   │   │   ├── ports/outbound/
│   │   │   │   └── profile_repository_port.dart
│   │   │   └── use_cases/
│   │   │       └── save_profile_use_case.dart
│   │   ├── adapters/
│   │   │   ├── inbound/
│   │   │   │   └── profile_screen.dart
│   │   │   └── outbound/
│   │   │       ├── http_profile_repository.dart  (TBD)
│   │   │       └── client_profile_codec.dart
│   │   └── composition/
│   │       └── profile_provider.dart
│   │
│   ├── home/
│   │   └── adapters/inbound/
│   │       └── home_screen.dart                Tab nav (Home, History, Cars, Profile)
│   │
│   ├── booking/
│   │   └── adapters/inbound/
│   │       ├── booking_screen.dart              Service picker + description
│   │       └── booking_confirm_screen.dart      Summary + date picker
│   │
│   └── onboarding/
│       └── adapters/inbound/
│           └── onboarding_screen.dart           Intro slides
│
├── core/
│   ├── router/
│   │   └── app_router.dart                  go_router routes + auth redirect
│   ├── config/
│   │   ├── app_environment.dart              --dart-define reader (local/remote)
│   │   └── app_defaults.dart                 Constants (default values)
│   ├── network/
│   │   └── dio_provider.dart                 HTTP client + JWT interceptor
│   ├── storage/
│   │   ├── session_storage.dart               abstract interface
│   │   ├── secure_storage_session_storage.dart flutter_secure_storage impl
│   │   └── shared_preferences_wrapper.dart   SharedPreferences helper
│   ├── theme/
│   │   ├── app_colors.dart                   Color tokens (primary, error, etc.)
│   │   ├── app_typography.dart               TextStyle tokens
│   │   ├── app_spacing.dart                  Padding/margin tokens (xs…xxxl)
│   │   ├── app_radii.dart                    Border radius tokens
│   │   └── app_theme.dart                    MaterialTheme (buttons, text fields)
│   ├── util/
│   │   ├── date_format.dart                  formatHm, formatDdMmHm
│   │   ├── jwt_payload.dart                  Parse exp claim
│   │   ├── validators.dart                   Phone, plate, etc. validation
│   │   └── id_generator.dart                 Microsecond-based IDs
│   ├── widgets/
│   │   ├── app_shell.dart                    Bottom nav container
│   │   ├── empty_state.dart                  Icon + title + subtitle
│   │   ├── error_state.dart                  Offline + retry
│   │   ├── button_spinner.dart               Async submit button
│   │   ├── confirm_dialog.dart               showConfirmDialog helper
│   │   └── stat_card.dart                    Metric card (mileage, ETA)
│   ├── dev/
│   │   ├── api_base_override.dart            Profile screen API URL editor
│   │   └── showcase_screen.dart              Design tokens showcase
│   ├── telemetry/
│   │   ├── sentry.dart                       Sentry bootstrap (optional DSN)
│   │   └── error_reporting.dart              reportError wrapper
│   └── l10n/
│       ├── app_uk.arb                        Ukrainian strings (future)
│       ├── app_en.arb                        English strings (future)
│       └── generated/
│           └── app_localizations.dart        Auto-generated (flutter gen-l10n)
│
└── test/
    ├── _helpers/
    │   ├── test_app.dart                     pumpScreen() helper
    │   └── fakes.dart                        Shared fake ports
    ├── features/
    │   └── <feature>/
    │       ├── domain/
    │       ├── application/use_cases/
    │       └── adapters/outbound/
    └── widget_test.dart                      Smoke test: app starts
```

## Key Concepts

### Hexagonal Architecture
Each feature is self-contained with three rings:
1. **Domain:** Pure Dart entities (Vehicle, ActiveOrder, Session)
2. **Application:** Use cases + port abstractions
3. **Adapters:** HTTP/SharedPrefs implementations + UI screens

Dependency rule: outer → inner (adapters depend on application, not reverse).

### State Management (Riverpod)
- **Read flows:** `FutureProvider.autoDispose` (auto-cleanup on unmount)
- **Write flows:** `AsyncNotifier` controllers (AuthController, VehiclesController)
- **Detail screens:** `.family` providers keyed by ID

### Environment Switching
- **Local mode:** SharedPrefs + Fake adapters (offline, fast)
- **Remote mode:** HTTP adapters (talks to middleware at staging)
- Override via `--dart-define=APP_ENV=local|remote`

### Error Handling
- OTP errors mapped to `OtpRequestException(failure, retryAfterSec)`
- HTTP errors caught in adapters → domain exceptions
- Controllers log + show toast to user

## Request Flow Examples

### OTP Authentication
```
1. OtpRequestScreen → user types phone
2. authController.requestOtp(phone)
   ├─ requestOtpUseCase.call(phone)
   │  └─ otpGatewayPort.request(phone)
   │     └─ HttpOtpGateway.request() [if remote]
   │        └─ HTTP POST /v1/auth/otp/request → challengeId
   └─ authController.state = AsyncData(challengeId)
3. go_router navigates to OtpVerifyScreen
4. User enters code → authController.verifyOtp(code)
   ├─ verifyOtpUseCase.call(code)
   │  └─ otpGatewayPort.verify(challengeId, code)
   │     └─ HttpOtpGateway.verify() [if remote]
   │        └─ HTTP POST /v1/auth/otp/verify → accessToken + refreshToken
   └─ sessionStorage.write(accessToken, refreshToken)
5. go_router redirects to /home
```

### Vehicles List
```
1. CarsListScreen mounts → watches vehiclesProvider
2. vehiclesProvider triggers vehicleRepositoryPort.findAll()
3. HttpVehicleRepository.findAll() [if remote]
   └─ HTTP GET /v1/vehicles → Array<Vehicle>
4. Dio interceptor attaches Authorization: Bearer <accessToken>
5. Response parsed via vehicleFromMap codec
6. UI renders list with edit/delete actions
7. Screen unmounts → vehiclesProvider.autoDispose invalidates
```

## Test Coverage

**57/57 tests passing**

- Use-case tests: inject FakeXxx ports, assert state changes
- Adapter tests: mock SharedPrefs/Dio, assert parsing
- Widget tests: pumpScreen with local environment, assert navigation

## Development Workflow

```bash
# Local (no HTTP)
flutter run -d <device>
# App defaults to APP_ENV=remote, pointing to staging
# Override in Profile → "Сервер API" for testing

# Remote with local middleware
flutter run -d <device> --dart-define=API_URL=http://localhost:8787/v1

# Run tests
flutter test

# Analyze
flutter analyze

# Generate codelocs
flutter gen-l10n

# Code format
dart format lib/ test/
```

## Staging Environment

**Default API base:** `https://autohub.bmolodan.dev/v1`

**Accessible from real device** via Cloudflare Tunnel (see parent CLAUDE.md for tunnel setup).

**Dev overrides:** Profile → "Сервер API" → paste URL → hot-restart (persists in SharedPrefs `dev.api_base_url`)

## Common Debugging

**"unauthorized" on vehicles list:**
- Check JWT in secure storage (Profile → see phone)
- Check token not expired (compare `DateTime.now()` to JWT exp claim)
- Relaunch app to refresh token

**"invalid_phone" on OTP request:**
- Normalize check: `380XXXXXXXXX` (12 digits, starts with 380)
- Check for special characters or spaces

**Network timeout:**
- Check Cloudflare tunnel is running: `npm run tunnel` in middleware
- Check network connectivity
- Check API URL is correct (Profile → "Сервер API")

**Test failure:**
- Run `flutter pub get` (dependency lock)
- Run `flutter clean && flutter pub get`
- Check test environment override: `appEnvironmentProvider.overrideWithValue(AppEnvironment.local)`
