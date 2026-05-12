# Frontend

<!-- Generated: 2026-05-13 | Files scanned: 58 dart src | Token estimate: ~900 -->

Flutter 3.22+ / Dart 3.4+. State: Riverpod 2.5. Navigation: go_router 14.2.

## Route tree

```
/onboarding                      OnboardingScreen
/auth/phone                      PhoneScreen          (fmt: XX XXX XX XX + dev hint)
/auth/otp?challengeId&phone      OtpScreen            (code "0000" accepted)

ShellRoute (AppShell — bottom nav)
├─ /home                         HomeScreen
├─ /history                      HistoryScreen
├─ /cars                         CarsListScreen
└─ /profile                      ProfileScreen

/booking/service                 ServicePickerScreen      (step 1/3)
/booking/problem?serviceId       ProblemFormScreen        (step 3/3, posts order)
/cars/add                        AddCarScreen
/cars/detail/:id                 CarDetailScreen
/orders/:id                      OrderDetailScreen
/profile/notifications           NotificationsScreen
/profile/account/delete          AccountDeleteScreen
/dev/showcase                    ThemeShowcase            (design tokens)
/dev/states                      StatesShowcase           (empty + error)
```

**Auth redirect** (app_router.dart:66): `_publicRoutes = {onboarding, phone, otp, dev/*}`. No session + private → onboarding. Session + auth/onboarding → home.
⚠ Known issue: redirect uses `ref.read` so it doesn't auto-refire on auth changes; sign-in/out works via explicit `context.go`.

## Screen → use case wiring

| Screen | Riverpod providers | Use cases reached |
|---|---|---|
| HomeScreen | `ordersControllerProvider` | GetActiveOrders |
| HistoryScreen | `serviceHistoryProvider(vehicleId)` | GetServiceHistory |
| CarsListScreen | `vehiclesControllerProvider` | ListVehicles |
| AddCarScreen | `vehiclesControllerProvider.notifier.add()` | AddVehicle |
| CarDetailScreen | `vehicleByIdProvider(id)` | GetVehicle |
| ProfileScreen | `vehiclesControllerProvider`, `authControllerProvider` | ListVehicles, SignOut |
| ServicePickerScreen | (local state) | — |
| ProblemFormScreen | `ordersControllerProvider.notifier.create()`, `vehiclesControllerProvider` | CreateOrder |
| OrderDetailScreen | `orderByIdProvider(id)` | GetOrderById |
| PhoneScreen | `authControllerProvider.notifier.requestCode()` | RequestOtp |
| OtpScreen | `authControllerProvider.notifier.verifyCode()` | VerifyOtp |
| AccountDeleteScreen | `authControllerProvider.notifier.signOut()` | SignOut |

## Controllers (AsyncNotifier)

- `AuthController` → `AsyncNotifier<Session?>` — `requestCode`, `verifyCode`, `signOut`
- `VehiclesController` → `AsyncNotifier<List<Vehicle>>` — `add`
- `OrdersController` → `AsyncNotifier<List<ActiveOrder>>` — `create` (optimistic append)

## Theme / tokens

Inter via google_fonts. Brand: mustard `#F0CC50` + near-black `#1A1A1A` on cream `#FAF9F6`.
- `AppColors`, `AppTypography`, `AppSpacing` (xxs..xxxl), `AppRadii` (xs..pill).
- Theme configured in `app_theme.dart`: pill ElevatedButton (yellow CTA), pill FilledButton (black secondary), pill OutlinedButton, surface-rounded TextFields, yellow Switch track on selected.

## Reusable widgets

```
core/widgets/
├── app_shell.dart           bottom nav over ShellRoute child
├── empty_state.dart         icon + title + subtitle + optional CTA
├── error_state.dart         wifi-off + retry + offline link
└── states_showcase.dart     /dev/states tabs
```

## Localization

Locale = `uk` (Ukrainian). `flutter_localizations` delegates wired. No ARB / AppLocalizations yet — strings hardcoded inline.
