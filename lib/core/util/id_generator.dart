import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clock.dart';

/// Mints opaque string ids. Inject so tests can produce deterministic ids.
abstract interface class IdGenerator {
  String next(String prefix);
}

/// Default impl: prefix-microsecondsSinceEpoch. Sufficient for offline use
/// while we don't have a server-issued id authority.
class EpochIdGenerator implements IdGenerator {
  const EpochIdGenerator(this._clock);
  final Clock _clock;

  @override
  String next(String prefix) =>
      '$prefix-${_clock.now().microsecondsSinceEpoch}';
}

/// Test override: yields prefix-0, prefix-1, prefix-2 in sequence.
class CountingIdGenerator implements IdGenerator {
  CountingIdGenerator();
  int _seq = 0;
  @override
  String next(String prefix) => '$prefix-${_seq++}';
}

final idGeneratorProvider = Provider<IdGenerator>(
  (ref) => EpochIdGenerator(ref.watch(clockProvider)),
);
