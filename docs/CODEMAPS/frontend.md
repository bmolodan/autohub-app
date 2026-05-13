# Frontend

<!-- Generated: 2026-05-13 | Files scanned: ~80 dart src | Token estimate: ~1000 -->

Flutter 3.22+ / Dart 3.4+. State: Riverpod 3.3. Navigation: go_router 17.2.

## Route tree

```
/onboarding                      OnboardingScreen
/auth/phone                      PhoneScreen          (fmt: XX XXX XX XX + dev hint)
/auth/otp?challengeId&phone      OtpScreen            (code "0000" accepted)

/register                        RegisterClientScreen (first-time profile)
/profile/edit                    RegisterClientScreen (editMode = true)

ShellRoute (AppShell — bottom nav)
├─ /home                         HomeScreen
├─ /history                      HistoryScreen
├─ /cars                         CarsListScreen
└─ /profile                      ProfileScreen

/booking/service                 ServicePickerScreen      (step 1/3 — supports custom title)
/booking/problem?serviceId       ProblemFormScreen        (step 3/3, posts order)
/booking/problem?customTitle     ProblemFormScreen        (custom-service variant)
/cars/add?next=                  AddCarScreen             (optional ?next= for empty-vehicle detour)
/cars/edit/:id                   AddCarScreen (editMode)
/cars/detail/:id                 CarDetailScreen
/orders/:id                      OrderDetailScreen
/profile/notifications           NotificationsScreen
/profile/account/delete          AccountDeleteScreen
/dev/showcase                    ThemeShowcase            (design tokens)
/dev/states                      StatesShowcase           (empty + error)
```

**Auth redirect** (`app_router.dart`): `_publicRoutes = {onboarding, phone, otp, dev/*}`. No session + private → onboarding. Session + auth/onboarding → home. Session + no profile yet → `/register`.

Refresh: `_RouterRefresh` listens to both `authControllerProvider` and `clientProfileControllerProvider`, so sign-in/out + profile save trigger redirect re-evaluation.

Deep-link query params are clamped via `_clamp(value, max)` to guard against malicious long strings. Typed keys live in `QueryParams` (`phone`, `challengeId`, `serviceId`, `customTitle`, `nextRoute`).

## Screen → use case wiring

| Screen | Riverpod providers | Use cases reached |
|---|---|---|
| HomeScreen | `ordersControllerProvider`, `vehiclesControllerProvider` | GetActiveOrders, ListVehicles |
| HistoryScreen | `serviceHistoryProvider(vehicleId)` | GetServiceHistory |
| CarsListScreen | `vehiclesControllerProvider` | ListVehicles |
| AddCarScreen | `vehiclesControllerProvider.notifier.add/update`, `carMakesProvider`, `carModelsProvider(make)` | AddVehicle, UpdateVehicle, catalog reads |
| CarDetailScreen | `vehicleByIdProvider(id)`, `vehiclesControllerProvider.notifier.delete` | GetVehicle, DeleteVehicle |
| ProfileScreen | `clientProfileControllerProvider`, `vehiclesControllerProvider`, `authControllerProvider` | GetClientProfile, ListVehicles, SignOut |
| RegisterClientScreen | `clientProfileControllerProvider.notifier.save()` | SaveClientProfile |
| ServicePickerScreen | (local state) | — |
| ProblemFormScreen | `ordersControllerProvider.notifier.create()`, `vehiclesControllerProvider` | CreateOrder |
| OrderDetailScreen | `orderByIdProvider(id)`, `ordersControllerProvider.notifier.cancel` | GetOrderById, CancelOrder |
| PhoneScreen | `authControllerProvider.notifier.requestCode()` | RequestOtp |
| OtpScreen | `authControllerProvider.notifier.verifyCode()` | VerifyOtp |
| AccountDeleteScreen | `wipeAccountUseCaseProvider` | WipeAccount |

## Controllers (AsyncNotifier)

- `AuthController` → `AsyncNotifier<Session?>` — `requestCode`, `verifyCode`, `signOut`
- `VehiclesController` → `AsyncNotifier<List<Vehicle>>` — `add`, `update`, `delete`
- `OrdersController` → `AsyncNotifier<List<ActiveOrder>>` — `create` (optimistic append), `cancel`
- `ClientProfileController` → `AsyncNotifier<ClientProfile?>` — `save`

## Theme / tokens

Inter via google_fonts. Brand: mustard `#F0CC50` + near-black `#1A1A1A` on cream `#FAF9F6`.
- `AppColors` (incl. `onError`), `AppTypography`, `AppSpacing` (xxs..xxxl), `AppRadii` (xs..pill), `AppIconSize` (sm..hero), `AppSizes` (avatar, iconBubble, otpSlotHeight, ctaMinHeight).
- Theme configured in `app_theme.dart`: pill ElevatedButton (yellow CTA), pill FilledButton (black secondary), pill OutlinedButton, surface-rounded TextFields, yellow Switch track on selected.

## Reusable widgets

```
core/widgets/
├── app_shell.dart           bottom nav over ShellRoute child (content clamped to 480pt)
├── empty_state.dart         icon + title + subtitle + optional CTA
├── error_state.dart         wifi-off + retry + offline link
├── states_showcase.dart     /dev/states tabs
├── button_spinner.dart      inline pill-button spinner for async submit states
├── confirm_dialog.dart      showConfirmDialog(...) helper — destructive / default flavours
└── stat_card.dart           hero metric block (mileage, ETA)
```

## Core utilities

```
core/util/
├── date_format.dart         formatHm / formatDdMmHm — never inline padLeft
├── validators.dart          UA-phone, UA-plate, non-empty / max-length validators
├── ua_plate_formatter.dart  TextInputFormatter — uppercase + Cyrillic→Latin normalize
├── clock.dart               Clock seam for tests
└── id_generator.dart        microsecond-based id generator (orders, vehicles)
```

## Localization

Locale: `uk` (Ukrainian), with `en` template available. ARB-based l10n is wired:
- `lib/l10n/app_uk.arb` + `app_en.arb` — source ARBs (ICU plurals supported)
- `lib/l10n/generated/app_localizations.dart` — generated by `flutter gen-l10n`
- `lib/l10n/l10n_extension.dart` — `context.l10n` extension

`MaterialApp.router` declares `localizationsDelegates: AppLocalizations.localizationsDelegates` + `supportedLocales`. Default `locale: const Locale('uk')`.

## Telemetry

`core/telemetry/sentry.dart`:
- `bootstrapSentry({required runApp})` — initialises Sentry if `--dart-define=SENTRY_DSN=...` is provided; otherwise runs `runApp` directly (zero-cost in dev).
- `reportError(error, stack)` — forwarded by `FlutterError.onError` and `PlatformDispatcher.instance.onError` in `main.dart`.

## Loading shimmer + Hero

- `Skeletonizer` (skeletonizer ^2.1) wraps loading branches in OrderDetail + History.
- `Hero(tag: 'order-hero-${order.id}')` wraps in-progress, pending, and canceled card bodies on Home + the matching detail-screen blocks for shared-element transitions.
