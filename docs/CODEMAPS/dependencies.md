# Flutter App Dependencies Codemap

**Last Updated:** 2026-06-11  
**Package Manager:** pub (pubspec.yaml)  
**Flutter Version:** ≥3.22, Dart ≥3.4

## Production Dependencies

| Package | Version | Purpose | Risk |
|---------|---------|---------|------|
| `flutter` | ≥3.22 | UI framework | Low — LTS support |
| `flutter_localizations` | sdk | Locale delegates (uk + en) | Low — builtin |
| `google_fonts` | ^8.1.0 | Inter typography | Low — asset-based |
| `flutter_riverpod` | ^3.3.1 | State + DI (AsyncNotifier, FutureProvider) | Low — widely adopted |
| `go_router` | ^17.2.3 | Navigation + deep linking + auth redirect | Low — Google-maintained |
| `dio` | ^5.5.0 | HTTP client (active for remote mode) | Low — 4000+ stars |
| `shared_preferences` | ^2.3.2 | Non-sensitive local storage (local mode) | Low — stable |
| `flutter_secure_storage` | ^10.3.1 | Encrypted token storage (Keychain/Android) | Low — widely used |
| `image_picker` | ^1.1.2 | Photo selection (order uploads) | Low — well-maintained |
| `skeletonizer` | ^2.1.3 | Loading skeleton animation | Low — simple |
| `intl` | any | Internationalization (ARB) | Low — Dart standard |
| `sentry_flutter` | ^9.20.0 | Error reporting (no-op if SENTRY_DSN unset) | Low — optional |

## Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | sdk | Unit + widget tests |
| `integration_test` | sdk | End-to-end tests (scaffolded) |
| `flutter_lints` | ^6.0.0 | Lint rules |

## Riverpod State Pattern

**Write flows:** AsyncNotifier (controllers)
```dart
final authControllerProvider = AsyncNotifierProvider<AuthController, AsyncValue<void>>(
  AuthController.new,
);
```

**Read flows:** FutureProvider (basic reads)
```dart
final vehiclesProvider = FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  return ref.watch(vehicleRepositoryProvider).findAll();
});
```

**Detail screens:** FutureProvider.family (keyed by ID)
```dart
final vehicleByIdProvider = FutureProvider.autoDispose.family<Vehicle?, String>((ref, id) async {
  return ref.watch(vehicleRepositoryProvider).findById(id);
});
```

## Navigation (go_router)

**File:** `lib/core/router/app_router.dart`

Route groups:
- Public: `/onboarding`, `/auth/otp/*`, `/dev/*`
- Auth-gated: everything else (redirect to onboarding if no session)
- Deep-link params clamped to prevent injection

## HTTP Client (Dio)

**File:** `lib/core/network/dio_provider.dart`

```dart
final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  
  // JWT interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (opts, handler) {
        final session = ref.read(sessionProvider);
        if (session != null) {
          opts.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        return handler.next(opts);
      },
    ),
  );
  
  return dio;
});
```

## Storage Providers

**Secure (Keychain/Encrypted):**
```dart
final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return SecureStorageSessionStorage();  // flutter_secure_storage
});
```

**Non-Sensitive (SharedPreferences):**
```dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main()');
});
```

Override in `main()` after `SharedPreferences.getInstance()`.

## Environment Configuration

**Build-time:** `--dart-define=APP_ENV=remote|local --dart-define=API_URL=https://...`

**Runtime:** SharedPrefs key `dev.api_base_url` (overrides build-time if set)

**File:** `lib/core/config/app_environment.dart`

```dart
const String apiBaseUrlDefault = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://autohub.bmolodan.dev/v1',
);

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  const env = String.fromEnvironment('APP_ENV', defaultValue: 'remote');
  return env == 'remote' ? AppEnvironment.remote : AppEnvironment.local;
});
```

## Localization (ARB)

**Files:**
- `lib/l10n/app_uk.arb` (Ukrainian)
- `lib/l10n/app_en.arb` (English)

**Generated:** `lib/l10n/generated/app_localizations.dart` (via `flutter gen-l10n`)

**Usage:**
```dart
final text = context.l10n.messageKey;  // extension in l10n_extension.dart
```

Currently: hardcoded Ukrainian UI. ARB infrastructure ready for future translations.

## Testing

**Run tests:**
```bash
flutter test                 # all tests
flutter test --coverage      # with coverage
```

**Test helpers:**
- `test/_helpers/test_app.dart` — `pumpScreen()` helper
- `test/_helpers/fakes.dart` — shared fake ports

**Mocking:**
```dart
class _FakeOtpGateway implements OtpGatewayPort {
  @override
  Future<OtpChallenge> request(String phone) async {
    return OtpChallenge(id: 'test-id', phone: phone);
  }
}

final dio = MockDio();
dio.get.expect('/vehicles').reply(200, vehicleJson);
```

## Adapter Switching (Local vs Remote)

**Composition pattern:** Environment-aware provider:

```dart
final vehicleRepositoryProvider = Provider<VehicleRepositoryPort>((ref) {
  final env = ref.watch(appEnvironmentProvider);
  if (env == AppEnvironment.local) {
    return LocalVehicleRepository(ref.watch(sharedPreferencesProvider));
  }
  return HttpVehicleRepository(ref.watch(dioProvider));
});
```

Test override:
```dart
ProviderContainer(
  overrides: [
    appEnvironmentProvider.overrideWithValue(AppEnvironment.local),
    vehicleRepositoryProvider.overrideWithValue(_FakeVehicleRepository()),
  ],
);
```

## Firebase (Deferred)

Currently commented in pubspec.yaml:
```yaml
# firebase_core: ^3.3.0
# firebase_auth: ^5.1.4
# firebase_messaging: ^15.0.4
```

When enabled:
- Auth → FirebaseAuth (replaces OTP middleware)
- Push → Firebase Cloud Messaging (device tokens)
- Analytics → Crashlytics (via Sentry)

## Package Update Strategy

**Riverpod/go_router:**
- Minor updates safe
- Major versions require architecture review
- Test all 57 tests after update

**Dio:**
- Patch + minor safe
- Major: test HTTP interceptors + error handling

**Flutter:**
- Follow LTS releases
- Test on iOS + Android

**Upgrade command:**
```bash
flutter pub outdated             # Check for updates
flutter pub upgrade              # Patch + minor only
flutter pub upgrade --major      # Major (manual review)
```

## Cleanup & Caching

**Riverpod cleanup:**
- `.autoDispose` providers auto-cleanup on unmount (saves memory for detail screens)

**Network cache:**
- No HTTP caching layer; Riverpod state is cache
- `ref.invalidate(vehiclesProvider)` forces re-fetch

**Storage:**
- `SharedPreferences.remove(key)` for explicit deletion
- Secure storage auto-expires on app uninstall

