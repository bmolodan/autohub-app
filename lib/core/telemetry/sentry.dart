import 'package:sentry_flutter/sentry_flutter.dart';

/// Initialises Sentry if `SENTRY_DSN` is provided at build time, then runs
/// [runApp]. With no DSN the SDK is bypassed entirely — dev/local builds
/// pay zero runtime cost and produce no events.
///
/// Build invocation for staging/prod:
///   flutter run --dart-define=SENTRY_DSN=https://...@sentry.io/...
Future<void> bootstrapSentry({
  required Future<void> Function() runApp,
}) async {
  const dsn = String.fromEnvironment('SENTRY_DSN');
  if (dsn.isEmpty) {
    await runApp();
    return;
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = dsn;
      options.tracesSampleRate = 0.2;
      options.environment =
          const String.fromEnvironment('APP_ENV', defaultValue: 'local');
    },
    appRunner: runApp,
  );
}

/// Forwards an error to Sentry when configured; otherwise a no-op so
/// the global error handlers in `main.dart` can call it unconditionally.
void reportError(Object error, StackTrace? stack) {
  // SentryFlutter.init wires Hub before any reports flow; if init was
  // skipped, captureException is a noop on the default Hub.
  Sentry.captureException(error, stackTrace: stack);
}
