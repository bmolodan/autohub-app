import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide SharedPreferences instance. Override in main() once `getInstance()`
/// resolves; tests override with their own seeded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);
