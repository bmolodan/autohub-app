import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local = SharedPreferences + fakes (offline dev default).
/// Remote = HTTP adapters hitting [apiBaseUrlProvider].
enum AppEnvironment { local, remote }

/// Pass at build time to force offline/fake mode:
///   flutter run --dart-define=APP_ENV=local
/// Default is remote — debug builds talk to staging.
const _envName = String.fromEnvironment('APP_ENV', defaultValue: 'remote');

/// Compile-time fallback. Runtime override (SharedPrefs key `dev.api_base_url`)
/// takes precedence — see `core/dev/api_base_override.dart` and `main.dart`.
const String apiBaseUrlDefault =
    String.fromEnvironment('API_URL', defaultValue: 'https://autohub.bmolodan.dev/v1');

/// Effective API base URL. Override at the [ProviderScope] level in `main()`
/// when a runtime override is present; tests can override per-container.
final apiBaseUrlProvider = Provider<String>((_) => apiBaseUrlDefault);

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  const env =
      _envName == 'remote' ? AppEnvironment.remote : AppEnvironment.local;
  final baseUrl = ref.watch(apiBaseUrlProvider);
  assert(
    !(env == AppEnvironment.remote &&
        baseUrl.startsWith('http://') &&
        !baseUrl.contains('localhost')),
    'Remote environment must use HTTPS for non-localhost: $baseUrl',
  );
  return env;
});
