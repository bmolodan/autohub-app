# Dependencies

<!-- Generated: 2026-05-13 | pubspec scanned | Token estimate: ~500 -->

## Active runtime deps

| Package | Version | Used for |
|---|---|---|
| `flutter` | sdk | Framework |
| `flutter_localizations` | sdk | ARB delegates (uk + en) |
| `google_fonts` | ^8.1.0 | Inter typography |
| `flutter_riverpod` | ^3.3.1 | State / DI (breaking-bumped from 2.6 — `valueOrNull` → `value`, `Override` moved to `package:flutter_riverpod/misc.dart`) |
| `go_router` | ^17.2.3 | Navigation + auth/profile redirect |
| `dio` | ^5.5.0 | HTTP client (wired in `core/network/dio_provider.dart`; adapters not yet using it for backend-gated features) |
| `shared_preferences` | ^2.3.2 | Persistence (session, vehicles, orders, profile) |
| `image_picker` | ^1.1.2 | Booking photo selection |
| `skeletonizer` | ^2.1.3 | Loading shimmer (OrderDetail, History) |
| `sentry_flutter` | ^8.14.0 | Telemetry — bootstrap behind `--dart-define=SENTRY_DSN=...`; no-op when unset |
| `intl` | any | Date / number formatting + ARB code-gen |

## Dev deps

| Package | Version | Used for |
|---|---|---|
| `flutter_test` | sdk | Unit + widget tests |
| `integration_test` | sdk | End-to-end (scaffolded; no integration tests yet) |
| `flutter_lints` | ^6.0.0 | Default lint set |
| `shelf` | ^1.4.0 | Local Dart-only mock server: `dart run tool/mock_server.dart` |
| `shelf_router` | ^1.1.0 | Routing for the local mock server |

## Commented out (next-iteration candidates)

- `hive_flutter` — typed/indexed boxes (replace SharedPrefs if scale demands)
- `flutter_secure_storage` — encrypted session token store (gated on real JWTs)
- `firebase_core` / `firebase_auth` / `firebase_messaging` — real auth + push (gated on Firebase project + APN cert)

## External services

**None integrated.** All adapters local:
- `FakeOtpGateway` — accepts code "0000"
- Mock JSON assets (`service_history.json`, `orders_active.json`, `car_makes.json`)

## Assets

```
assets/mocks/
├── orders_active.json        (legacy — superseded by _seed.dart Dart constant)
└── service_history.json      (used by history feature)
assets/data/
└── car_makes.json            (make → models catalog for AddCarScreen picker)
```

## Build / platform

- iOS: Xcode project at `ios/`, target iPhone 17 sim (Simulator runtime iOS 26.5)
- Android: Gradle project at `android/` (not exercised in current session)
- macOS / web / linux / windows: scaffolds present in `flutter create` defaults — not configured

## Build invocation

- Dev: `flutter run -d <device-id>`
- Telemetry-enabled: `flutter run --dart-define=SENTRY_DSN=https://...@sentry.io/... --dart-define=APP_ENV=staging`
