# Flutter App Data & Storage Codemap

**Last Updated:** 2026-06-11  
**Local Storage:** SharedPreferences (non-sensitive) + flutter_secure_storage (tokens)  
**Codecs:** JSON ↔ Dart via dedicated codec files

## Session Storage (Secure)

**File:** `lib/core/storage/session_storage.dart`

Uses `flutter_secure_storage`:
- iOS: Keychain
- Android: EncryptedSharedPreferences

**Stored on successful OTP verify:**
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "token-hash",
  "phone": "380501234567",
  "createdAt": "2026-06-11T..."
}
```

Access via Riverpod:
```dart
final sessionProvider = FutureProvider<Session?>((ref) async {
  return ref.watch(sessionStorageProvider).read();
});
```

## Local Preferences (Non-Sensitive)

**File:** `lib/core/storage/shared_preferences_wrapper.dart`

| Key | Value | Purpose |
|-----|-------|---------|
| `dev.api_base_url` | String | Runtime API override (empty = disabled) |
| `local:vehicles:list` | JSON array | Cached vehicles (local mode) |
| `local:orders:list` | JSON array | Cached orders (local mode) |

## HTTP Codecs (JSON ↔ Dart)

All responses parsed via dedicated codec files with type safety.

### vehicle_codec.dart

```dart
Vehicle vehicleFromMap(Map<String, dynamic> json) => Vehicle(
  id: json['id'] as String,
  make: json['make'] as String,
  model: json['model'] as String,
  year: json['year'] as int,
  plate: json['plate'] as String,
  vin: json['vin'] as String?,
  mileageKm: json['mileageKm'] as int? ?? 0,
  nextServiceMileageKm: json['nextServiceMileageKm'] as int?,
);

Map<String, dynamic> vehicleToMap(Vehicle v) => {
  'id': v.id,
  'make': v.make,
  'model': v.model,
  'year': v.year,
  'plate': v.plate,
  'vin': v.vin,
  'mileageKm': v.mileageKm,
  'nextServiceMileageKm': v.nextServiceMileageKm,
};
```

### active_order_codec.dart

```dart
ActiveOrder activeOrderFromMap(Map<String, dynamic> json) => ActiveOrder(
  id: json['id'] as String,
  title: json['title'] as String,
  status: _parseStatus(json['status'] as String),
  vehicle: _parseVehicle(json['vehicle'] as Map),
  progress: json['progress'] as int?,
  eta: json['eta'] as String?,
  scheduledFor: json['scheduled_for'] as String?,
  totalUah: null,  // Always null (pricing stripped)
  timeline: [],
  photos: [],
);

ActiveOrderStatus _parseStatus(String s) {
  return switch (s) {
    'in_progress' => ActiveOrderStatus.inProgress,
    'pending_confirmation' => ActiveOrderStatus.pendingConfirmation,
    'canceled' => ActiveOrderStatus.canceled,
    _ => throw FormatException('Unknown status: $s'),
  };
}
```

### otp_codec.dart

```dart
OtpChallenge otpChallengeFromMap(Map<String, dynamic> json) =>
  OtpChallenge(id: json['challengeId'] as String, phone: json['phone'] as String);

Session sessionFromMap(Map<String, dynamic> json) => Session(
  phone: json['phone'] as String,
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  accessExpiresAt: jwtExpiresAt(json['accessToken'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
);
```

## JWT Handling

**File:** `lib/core/util/jwt_payload.dart`

```dart
/// Parse exp claim from JWT (Unix timestamp seconds).
DateTime jwtExpiresAt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) throw FormatException('Invalid JWT');
  
  final payload = utf8.decode(base64Url.decode(parts[1] + '=='));
  final json = jsonDecode(payload) as Map<String, dynamic>;
  final exp = json['exp'] as int?;
  
  if (exp == null) throw FormatException('Missing exp claim');
  return DateTime.fromMillisecondsSinceEpoch(exp * 1000).toUtc();
}
```

Used to detect access token expiry before API calls.

## Domain Entities

| Entity | File | Purpose |
|--------|------|---------|
| `Vehicle` | `features/cars/domain/vehicle.dart` | Car make/model/year/plate/VIN |
| `ActiveOrder` | `features/orders/domain/active_order.dart` | Order with status (in_progress, pending, canceled) |
| `Session` | `features/auth/domain/session.dart` | JWT + phone + creation timestamp |
| `ServiceRecord` | `features/history/domain/service_record.dart` | Past service entry (read-only) |
| `ClientProfile` | `features/profile/domain/client_profile.dart` | Name + phone + email |

**ActiveOrder:** Sealed union by status with optional fields:
```dart
enum ActiveOrderStatus { inProgress, pendingConfirmation, canceled }

class ActiveOrder {
  final String id, title;
  final ActiveOrderStatus status;
  final int? progress;  // null if not in_progress
  final String? eta;    // null if no ETA
  // ...
}
```

## State Controller Optimization

**Optimistic updates:** Modify local state before server response.

```dart
Future<void> add(Vehicle v) async {
  // 1. Update local state immediately
  state = AsyncData([...state.valueOrNull ?? [], v]);
  
  // 2. Persist
  try {
    await _repo.save(v);
  } catch (e) {
    // 3. Revert on error
    state = AsyncData([...state.valueOrNull ?? []..remove(v)]);
    rethrow;
  }
}
```

## Error Serialization

**OtpRequestException:**
```dart
enum OtpRequestFailure {
  cooldown,        // 429, wait retryAfterSec
  dailyCap,        // 429, wait retryAfterSec
  invalidPhone,    // 400
  smsFailed,       // 502
  network,         // Timeout or connection error
}

class OtpRequestException implements Exception {
  final OtpRequestFailure failure;
  final int? retryAfterSec;
}
```

Mapped from middleware HTTP responses:
- `429 otp_cooldown` → `failure.cooldown` + retryAfterSec
- `429 otp_daily_cap_reached` → `failure.dailyCap` + retryAfterSec
- `400 invalid_phone` → `failure.invalidPhone`
- `502 sms_send_failed` → `failure.smsFailed`
- Timeout/network → `failure.network`

## Seed Data

**File:** `lib/features/<feature>/adapters/outbound/_seed.dart`

Fixture data for local mode:

```dart
final _seedVehicles = [
  Vehicle(
    id: 'v1',
    make: 'Toyota',
    model: 'Camry',
    year: 2020,
    plate: 'AA1234BB',
    vin: null,
    mileageKm: 15000,
    nextServiceMileageKm: 20000,
  ),
];

List<Vehicle> seedVehicles() => [..._seedVehicles];  // defensive copy
```

## API Response Shapes (from Middleware)

### OTP Request
```json
{ "challengeId": "550e8400-e29b-41d4-a716-446655440000" }
```

### OTP Verify
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "token-hash",
  "profile": { "phone": "380501234567", "personId": null }
}
```

### Vehicle
```json
{
  "id": "123",
  "make": "Toyota",
  "model": "Camry",
  "year": 2020,
  "plate": "AA1234BB",
  "vin": "JTNBE...",
  "mileageKm": 0,
  "nextServiceMileageKm": null
}
```

### ActiveOrder
```json
{
  "id": "456",
  "title": "Заміна масла",
  "status": "in_progress",
  "vehicle": { "make": "Toyota", "model": "Camry", "plate": "AA1234BB" },
  "progress": null,
  "eta": null,
  "scheduled_for": "2026-06-15T09:00:00Z",
  "total_uah": null,
  "timeline": [],
  "photos": []
}
```

## Date Handling

**Wire format:** ISO 8601 UTC (e.g., `"2026-06-15T09:00:00Z"`)

```dart
// Parse
DateTime dt = DateTime.parse('2026-06-15T09:00:00Z').toUtc();

// Display (use util functions only)
String s = formatHm(dt);        // "14:30"
String s = formatDdMmHm(dt);    // "15.06 14:30"
```

Never `DateTime.toString()` or inline formatting.

## Cache Invalidation

- **On app relaunch:** No persistent cache (Riverpod memory-only)
- **On screen unmount:** `.autoDispose` providers clean up automatically
- **Manual refresh:** Controller method or pull-to-refresh

Example:
```dart
final vehiclesProvider = FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  return ref.watch(vehicleRepositoryProvider).findAll();
});
// Unmounted → invalidated → next watch re-fetches
```

