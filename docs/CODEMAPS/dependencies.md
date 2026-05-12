# Dependencies

<!-- Generated: 2026-05-13 | pubspec scanned | Token estimate: ~400 -->

## Active runtime deps

| Package | Version | Used for |
|---|---|---|
| `flutter` | sdk | Framework |
| `flutter_localizations` | sdk | Global delegates (uk + en) |
| `google_fonts` | ^6.2.1 | Inter typography |
| `flutter_riverpod` | ^2.5.1 | State / DI |
| `go_router` | ^14.2.0 | Navigation + auth redirect |
| `shared_preferences` | ^2.3.2 | Persistence (session + vehicles + orders) |

## Dev deps

| Package | Version | Used for |
|---|---|---|
| `flutter_test` | sdk | Unit + widget tests (57 passing) |
| `flutter_lints` | ^4.0.0 | Default lint set |

## Commented out (declared as next-iteration candidates)

- `dio` / `retrofit` — HTTP client when backend lands
- `hive_flutter` — typed/indexed boxes (replace SharedPrefs)
- `flutter_secure_storage` — encrypted session token store
- `firebase_core` / `firebase_auth` / `firebase_messaging` — real auth + push
- `mocktail` — test doubles (currently using hand-rolled fakes)

## External services

**None integrated.** All adapters local:
- `FakeOtpGateway` — accepts code "0000"
- Mock JSON assets (`service_history.json`, `orders_active.json`)

## Assets

```
assets/mocks/
├── orders_active.json     (legacy — superseded by _seed.dart Dart constant)
└── service_history.json   (used by history feature)
```

## Build / platform

- iOS: Xcode project at `ios/`, target iPhone 17 sim (Simulator runtime iOS 26.5)
- Android: Gradle project at `android/` (not exercised in current session)
- macOS / web / linux / windows: scaffolds present in `flutter create` defaults — not configured
