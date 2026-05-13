# Architecture

<!-- Generated: 2026-05-13 | Files scanned: ~80 dart src + ~43 dart tests + 2 mock JSON + 1 asset JSON | Token estimate: ~750 -->

Single Flutter app, single device target (currently iOS sim). Feature-first hexagonal layout per feature.

## Hexagonal pattern (per feature)

```
lib/features/<feature>/
├── domain/                  Pure Dart entities/value-objects. No framework imports.
├── application/
│   ├── ports/outbound/      abstract interface class — what the app needs from infra.
│   └── use_cases/           Pure orchestration. Constructor-inject the ports.
├── adapters/
│   ├── inbound/             ConsumerWidget / ConsumerStatefulWidget — UI layer.
│   └── outbound/            Implementations of outbound ports (SharedPrefs / asset / HTTP).
├── composition/             Riverpod providers wiring adapters into use cases.
└── presentation/            Legacy pure-UI screens (onboarding, auth, booking).
```

Dependency direction: `adapters → application → domain`. Inner rings never import outer.

## Feature inventory

| Feature | Layers present | Status |
|---|---|---|
| `auth` | domain, application, adapters/outbound, composition, presentation | Fully hexagonal. Sign-in / sign-out. |
| `cars` | domain, application, adapters/inbound+outbound, composition | Fully hexagonal. List / detail / add / edit / delete + make/model picker. |
| `history` | domain, application, adapters/inbound+outbound, composition | Fully hexagonal (read-only). |
| `orders` | domain, application, adapters/inbound+outbound, composition | Fully hexagonal. Create / get / list / cancel / updateProgress. |
| `profile` | domain, application, adapters/inbound+outbound, composition, presentation | Fully hexagonal. Registration, edit, account-wipe. |
| `home` | presentation only | Inbound widget over `orders` + `vehicles` (archive partition + Hero + booking detour). |
| `booking` | data + presentation | Service catalog + screens. Writes via `orders.CreateOrder`. |
| `onboarding` | presentation only | Static intro slides. |

## Shared / core

```
lib/core/
├── router/app_router.dart            go_router + auth + profile redirect; QueryParams
├── storage/shared_prefs_provider.dart Riverpod provider; overridden in main()
├── network/dio_provider.dart         HTTP client provider (for backend-ready adapters)
├── config/app_environment.dart       --dart-define env reader
├── theme/                            Tokens (colors, spacing, radii, typography, sizes, app_theme)
├── telemetry/sentry.dart             Sentry bootstrap + reportError (no-op without DSN)
├── util/                             date_format, validators, ua_plate_formatter, clock, id_generator
└── widgets/                          app_shell, empty_state, error_state, button_spinner,
                                      confirm_dialog, stat_card, states_showcase
```

## Composition root

`main.dart`:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `_wireGlobalErrorHandling()` — sets `FlutterError.onError` and `PlatformDispatcher.instance.onError` to report through `reportError(...)`. Custom `ErrorWidget.builder` in release mode renders a branded fallback.
3. `await bootstrapSentry(runApp: ...)` — initialises Sentry if `--dart-define=SENTRY_DSN=...` provided, otherwise straight to `runApp`.
4. Inside the closure: `await SharedPreferences.getInstance()`, override `sharedPreferencesProvider`, mount `AutoHubApp`.

Every feature's composition file owns its own Riverpod providers and is the only place adapters are constructed.

## Test layout

Tests mirror the feature/layer tree:
```
test/features/<feature>/{application,adapters,presentation,domain}/...
test/_helpers/                test_app.dart (pumpScreen), fakes.dart (shared in-memory ports)
test/widget_test.dart         smoke: app starts on onboarding
```

**Test totals**: 176/176 passing. Use-case tests use fake ports. Adapter tests use `SharedPreferences.setMockInitialValues({})`. Widget tests use the `pumpScreen` helper, which builds a `ProviderScope` with shared fakes from `test/_helpers/fakes.dart`.
