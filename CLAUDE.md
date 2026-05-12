# AutoHub — Project Instructions

Customer-facing Flutter app for NESEMOS Veteran Auto Hub (STO). Ukrainian-first UI. Hexagonal architecture per feature.

## Tech Stack
- Flutter ≥ 3.22, Dart ≥ 3.4
- Riverpod 2.5 (state + DI)
- go_router 14.2 (navigation)
- shared_preferences 2.3 (persistence)
- google_fonts (Inter typography)
- flutter_localizations (uk + en delegates wired; no .arb yet)

## Architecture

Hexagonal layout **per feature** under `lib/features/<name>/`:

```
domain/                pure Dart entities/value objects
application/
  ports/outbound/      abstract interface — what infra must provide
  use_cases/           orchestration; constructor-injects ports
adapters/
  inbound/             ConsumerWidget UI; consumes use cases
  outbound/            port impls (SharedPrefs, mock, http-future)
composition/           Riverpod providers wiring adapters → use cases
presentation/          legacy pure-UI screens (onboarding, auth, profile)
```

Dependency direction: adapters → application → domain. Domain imports nothing infra.

Detailed maps: `docs/CODEMAPS/{architecture,frontend,data,dependencies,features}.md`

## Build & Run
- Dev (iOS sim): `flutter run -d <device-id>`
- Format: `dart format lib/ test/`
- Analyze: `flutter analyze`
- Tests: `flutter test`

## Testing

- TDD: write failing tests before code. Compile-time RED counts.
- Use-case tests use **fake ports** (`class _FakeRepo implements XxxPort`).
- Adapter tests use `SharedPreferences.setMockInitialValues({})`.
- Tests mirror `lib/` structure at `test/features/<feature>/...`.
- Current count: **57/57 passing.**

## Code Style

- Hardcoded UI strings in Ukrainian (l10n is a follow-up).
- Domain entities: `final` fields, manual `==`/`hashCode` (currently id-only on some — `ActiveOrder`).
- Sealed-by-status pattern via `enum` + nullable optional fields (see `ActiveOrder`).
- Codec extraction (`active_order_codec.dart`) when same JSON shape is used for both seed + persistence; otherwise inline `_toJson/_fromJson` in the adapter.
- Use `AppSpacing.*` / `AppRadii.*` / `AppColors.*` / `AppTypography.*` — never raw numbers/strings for theme values.
- Date formatting: `formatHm(dt)` / `formatDdMmHm(dt)` in `core/util/date_format.dart`. Never inline `padLeft(2, '0')`.

## Patterns

### Adding a new feature
1. Start with use-case tests against a fake port. Get RED.
2. Add domain, port, use case. Get GREEN.
3. Add outbound adapter + adapter tests.
4. Add Riverpod composition (port → use case → Controller AsyncNotifier).
5. Add inbound widget. Wire from router.

### State management
- One controller per write feature (`AuthController`, `VehiclesController`, `OrdersController`) — `AsyncNotifier`.
- Read-only flows use plain `FutureProvider` or `FutureProvider.family.autoDispose`.
- Detail screens use `autoDispose.family` providers.
- Optimistic update: `state = AsyncData([...state.valueOrNull ?? [], created])`.
- Always await `_prefs.setString` — adapters' `_writeAll` returns `Future<void>`.

### Mounted checks
- Every `await` followed by `context.*` needs `if (!context.mounted) return;` (use `context.mounted`, not `mounted`, when calling from `ConsumerWidget` lambdas).
- `ConsumerStatefulWidget`: `if (!mounted) return;` after each await before `context.*` or `setState`.

### Router
- Routes in `lib/core/router/app_router.dart`.
- Auth-gated: not in `_publicRoutes` → redirect to onboarding if no session.
- Booking flow + cars/order detail use full-screen push routes (outside the ShellRoute tab nav).

## Conventions

- File naming: `snake_case.dart`.
- Class naming: `PascalCase`; private widgets/helpers prefixed `_`.
- Test files: `<thing>_test.dart` mirroring `lib/` path.
- No git in this repo yet — no commit conventions to enforce.

## Where to Look

| I want to... | Look at... |
|---|---|
| Add a screen + business logic | `lib/features/<feature>/{domain,application,adapters/inbound,composition}/` |
| Add persistence | `lib/features/<feature>/adapters/outbound/shared_prefs_*.dart` + override `xxxRepositoryProvider` |
| Change a route | `lib/core/router/app_router.dart` |
| Add a design token | `lib/core/theme/*` |
| Add a reusable widget | `lib/core/widgets/` |
| Add a util | `lib/core/util/` |

## Out of scope (current state)

- No real backend — all adapters are `Fake*`, `Mock*`, `SharedPrefs*`, or asset readers.
- No auth provider — `FakeOtpGateway` accepts code `0000`.
- No `.arb` localization — strings hardcoded.
- No global error reporting (no `FlutterError.onError` / `ErrorWidget.builder` hooks in `main.dart`).

## Mockups

`mockup/Screenshot 2026-05-11 at *.png` — 18 design screens covering onboarding, auth, booking, history, cars, profile, notifications, empty/error states, account deletion.
