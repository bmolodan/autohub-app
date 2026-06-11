# Flutter App Frontend Codemap

**Last Updated:** 2026-06-11  
**UI Framework:** Flutter 3.22+  
**HTTP Client:** Dio 5.5.0 (with custom interceptors)

## HTTP Adapters (Active)

All adapters inherit from port interfaces and are wired via Riverpod composition.

### HttpOtpGateway

**File:** `lib/features/auth/adapters/outbound/http_otp_gateway.dart`

```dart
class HttpOtpGateway implements OtpGatewayPort {
  Future<OtpChallenge> request(String phone) async {
    // POST /auth/otp/request { phone }
    // Response: { challengeId }
    // Errors:
    //   - 429 otp_cooldown → OtpRequestException(cooldown, retryAfterSec)
    //   - 429 otp_daily_cap_reached → OtpRequestException(dailyCap, retryAfterSec)
    //   - 400 invalid_phone → OtpRequestException(invalidPhone)
    //   - 502 sms_send_failed → OtpRequestException(smsFailed)
    //   - Other → OtpRequestException(network)
  }

  Future<Session> verify({
    required String challengeId,
    required String code,
  }) async {
    // POST /auth/otp/verify { challengeId, code }
    // Response: { accessToken, refreshToken, profile: { phone, personId } }
    // Errors: 401 → InvalidOtpException()
  }
}
```

### HttpVehicleRepository

**File:** `lib/features/cars/adapters/outbound/http_vehicle_repository.dart`

Implements read-only vehicles from RoApp (via middleware):
```dart
class HttpVehicleRepository implements VehicleRepositoryPort {
  Future<List<Vehicle>> findAll() async;       // GET /vehicles
  Future<Vehicle?> findById(String id) async;  // GET /vehicles/:id
  Future<void> save(Vehicle v) async;          // 501 Not Implemented (Phase B+)
  Future<void> delete(String id) async;        // 501 Not Implemented
  Future<void> clear() async;                  // UnimplementedError
}
```

### HttpActiveOrderRepository

**File:** `lib/features/orders/adapters/outbound/http_active_order_repository.dart`

Handles active orders + booking creation:
```dart
class HttpActiveOrderRepository implements ActiveOrderRepositoryPort {
  Future<List<ActiveOrder>> findAll() async;      // GET /orders
  Future<ActiveOrder?> findById(String id) async; // GET /orders/:id
  Future<void> save(ActiveOrder order) async;     // POST /orders (booking) — TBD
  Future<void> cancel(String id) async;           // POST /orders/:id/cancel — TBD
}
```

### HttpServiceHistoryRepository

**File:** `lib/features/history/adapters/outbound/http_service_history_repository.dart`

```dart
class HttpServiceHistoryRepository implements ServiceHistoryRepositoryPort {
  Future<List<ServiceHistory>> findAll() async;  // GET /history
}
```

## Composition Wiring (Riverpod)

Each feature's composition file binds adapters to use cases via Riverpod providers.

**Pattern:**
1. Port provider (HTTP or Fake)
2. UseCase provider (injects port)
3. Controller provider (AsyncNotifier, injects use cases)

Example:
```dart
// features/auth/composition/otp_gateway_provider.dart
final otpGatewayProvider = Provider<OtpGatewayPort>((ref) {
  final dio = ref.watch(dioProvider);
  return HttpOtpGateway(dio);
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});
```

Test override:
```dart
ProviderContainer(
  overrides: [
    appEnvironmentProvider.overrideWithValue(AppEnvironment.local),
    otpGatewayProvider.overrideWithValue(_FakeOtpGateway()),
  ],
);
```

## Screen Navigation & Lifecycle

### OTP Flow
1. `OtpRequestScreen` → user types phone + presses request
2. `authController.requestOtp(phone)` triggers HTTP POST
3. On success: challengeId + phone stored in authController state
4. go_router transitions to `OtpVerifyScreen`
5. User enters 6-digit code → `authController.verifyOtp(code)`
6. On success: accessToken + refreshToken stored in secure storage
7. go_router redirects to `/home`

### Cars Flow
1. `CarsListScreen` → `ref.watch(vehiclesProvider)` triggers HTTP GET
2. On success: renders list with edit/delete actions
3. Tap car → `GoRoute('/car/:id', ..., builder: CarDetailScreen())`
4. Detail screen watches `.family.autoDispose` provider keyed by id
5. Edit/delete actions call `vehiclesController` methods

### Mounted Guards
Every `await` followed by `context.*` call must be guarded:
```dart
await someAsync();
if (!context.mounted) return;  // or if (!mounted) in ConsumerStatefulWidget
context.showSnackBar(...);
```

## OTP Screen Details

**File:** `lib/features/auth/adapters/inbound/otp_verify_screen.dart`

- **Input:** 6-digit code via TextField
- **Security:** ClipRect + SizedBox hide underlying TextField
- **Lifecycle:** WidgetsBindingObserver hooks for app lifecycle
- **Back Prevention:** Disable back button to prevent returning to request screen
- **Error Messages (Ukrainian):**
  - **cooldown:** "Спробуйте ще раз через {retryAfterSec}с"
  - **dailyCap:** "Ви досягли денного ліміту"
  - **invalidPhone:** "Невірний номер"
  - **smsFailed:** "Помилка відправки SMS"
  - **network:** "Помилка мережі"

## Remote Mode Restrictions

When `appEnvironmentProvider == AppEnvironment.remote`:
- **Vehicles:** Add/Edit/Delete buttons hidden (read-only from RoApp)
- **Orders:** Booking create route not mounted in router
- **Profile:** Edit disabled (read-only)

Vehicles are derived from RoApp orders; app-side creation is Phase B+ decision.

## Error Handling

**HTTP 4xx/5xx:**
- Caught in adapter → mapped to domain exception
- Controller logs + updates UI (error toast, retry button)

**Invalid JSON:**
- FormatException caught in adapter
- Treated as network error

**Network timeout:**
- DioException caught, handled as network error

## Codecs (JSON ↔ Dart)

Shared JSON shapes extracted to dedicated codec files.

**vehicle_codec.dart:**
```dart
Vehicle vehicleFromMap(Map<String, dynamic> m) => Vehicle(
  id: m['id'] as String,
  make: m['make'] as String,
  model: m['model'] as String,
  year: m['year'] as int,
  // ...
);

Map<String, dynamic> vehicleToMap(Vehicle v) => {
  'id': v.id,
  'make': v.make,
  // ...
};
```

**active_order_codec.dart:** Similar pattern for orders

## Theme & Design Tokens

Never hardcode raw values; always use:
- `AppColors.primary`, `AppColors.background`, `AppColors.onError`
- `AppSpacing.lg` (16.0), `AppSpacing.md` (8.0), `AppSpacing.xxs` (2.0)
- `AppRadii.md` (12.0), `AppRadii.pill` (999.0)
- `AppTypography.headline`, `AppTypography.body`

**Files:** `lib/core/theme/colors.dart`, `spacing.dart`, `radii.dart`, `typography.dart`, `app_theme.dart`

**Brand:** Mustard `#F0CC50` (CTA) + Near-black `#1A1A1A` (secondary) on Cream `#FAF9F6`

## Date Formatting

Always use utilities; never `padLeft(2, '0')` inline:

```dart
// core/util/date_format.dart
String formatHm(DateTime dt);        // "14:30"
String formatDdMmHm(DateTime dt);    // "13.05 14:30"
```

## Reusable Widgets

```
core/widgets/
├── app_shell.dart           Bottom nav over ShellRoute child
├── empty_state.dart         Icon + title + subtitle + CTA
├── error_state.dart         Wi-Fi off + retry + offline link
├── button_spinner.dart      Inline spinner for async submit
├── confirm_dialog.dart      showConfirmDialog helper (destructive/default)
└── stat_card.dart           Metric card (mileage, ETA, etc.)
```

## Localization

**Approach:** ARB-based (future; currently hardcoded Ukrainian)

Wired: `lib/l10n/` → `app_uk.arb`, `app_en.arb` → generated `app_localizations.dart`

Access: `context.l10n.messageKey`

## Testing Strategy

**Local (APP_ENV=local):**
- All adapters are FakeXxx (in-memory)
- No HTTP calls
- Fast, repeatable, offline

**Remote (APP_ENV=remote):**
- HTTP adapters active
- Points to `https://autohub.bmolodan.dev/v1` by default
- Tests override appEnvironmentProvider

Example:
```dart
testWidgets('Cars list loads', (tester) async {
  final container = ProviderContainer(
    overrides: [
      appEnvironmentProvider.overrideWithValue(AppEnvironment.remote),
      apiBaseUrlProvider.overrideWithValue('http://localhost:8787/v1'),
    ],
  );
  // ...
});
```

## Current Status

**57/57 tests passing**  
**All HTTP adapters active** (OTP, Vehicles, Orders, History)  
**Default to remote** (staging at `autohub.bmolodan.dev`)  
**AppEnvironment override available** (for widget tests)
