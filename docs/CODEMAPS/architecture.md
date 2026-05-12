# Architecture

<!-- Generated: 2026-05-13 | Files scanned: 58 dart src + 12 dart tests + 2 mock JSON | Token estimate: ~700 -->

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
└── presentation/            Legacy pure-UI screens (onboarding, auth, booking, profile).
```

Dependency direction: `adapters → application → domain`. Inner rings never import outer.

## Feature inventory

| Feature | Layers present | Status |
|---|---|---|
| `auth` | domain, application, adapters/outbound, composition, presentation | Fully hexagonal. Sign-in / sign-out. |
| `cars` | domain, application, adapters/inbound+outbound, composition | Fully hexagonal. List / detail / add. |
| `history` | domain, application, adapters/inbound+outbound, composition | Fully hexagonal (read-only). |
| `orders` | domain, application, adapters/inbound+outbound, composition | Fully hexagonal. Read + write. |
| `home` | presentation only | Inbound widget that consumes the `orders` feature. |
| `booking` | data + presentation | Service catalog + screens. Writes via `orders` use case. |
| `profile` | presentation only | UI consumes auth + cars composition. |
| `onboarding` | presentation only | Static 3-slide intro. |

## Shared / core

```
lib/core/
├── router/app_router.dart       go_router + auth redirect
├── storage/shared_prefs_provider.dart   Riverpod provider; overridden in main()
├── theme/                       Tokens (colors, spacing, radii, typography, app_theme)
├── util/date_format.dart        formatHm / formatDdMmHm
└── widgets/                     app_shell, empty_state, error_state, states_showcase
```

## Composition root

`main.dart` awaits `SharedPreferences.getInstance()`, overrides `sharedPreferencesProvider`, mounts `AutoHubApp`. Every feature's composition file owns its own Riverpod providers and is the only place adapters are constructed.

## Test layout

Tests mirror the feature/layer tree:
```
test/features/<feature>/{application,adapters}/...
test/widget_test.dart    smoke: app starts on onboarding
```
Tally: **57/57 passing.** Use-case tests use fake ports. Adapter tests use `SharedPreferences.setMockInitialValues({})`.
