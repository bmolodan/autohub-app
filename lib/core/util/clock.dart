import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wall-clock source. Inject into use cases so tests can pin time.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();
  @override
  DateTime now() => DateTime.now();
}

/// Test override: a clock pinned to a fixed instant.
class FixedClock implements Clock {
  const FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

final clockProvider = Provider<Clock>((_) => const SystemClock());
