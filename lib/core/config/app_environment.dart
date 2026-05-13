import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local = SharedPreferences + fakes (offline dev default).
/// Remote = HTTP adapters hitting [apiBaseUrl].
enum AppEnvironment { local, remote }

/// Pass at build time:
///   flutter run --dart-define=APP_ENV=remote --dart-define=API_URL=http://localhost:8080
const _envName = String.fromEnvironment('APP_ENV', defaultValue: 'local');

const String apiBaseUrl =
    String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');

final appEnvironmentProvider = Provider<AppEnvironment>((_) {
  const env =
      _envName == 'remote' ? AppEnvironment.remote : AppEnvironment.local;
  assert(
    !(env == AppEnvironment.remote &&
        apiBaseUrl.startsWith('http://') &&
        !apiBaseUrl.contains('localhost')),
    'Remote environment must use HTTPS for non-localhost: $apiBaseUrl',
  );
  return env;
});
