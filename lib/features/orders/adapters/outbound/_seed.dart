import '../../../../core/util/clock.dart';

/// Goes away once a real backend is wired in.
///
/// Builds the seed lazily so timestamps are anchored to `clock.now()` at
/// first construction — avoids the "stale ETA" problem on long-running
/// installs.
String buildActiveOrdersSeedJson(Clock clock) {
  final now = clock.now();
  String iso(Duration offset) => now.add(offset).toIso8601String();

  return '''
[
  {
    "id": "4521",
    "title": "Заміна гальмівних колодок",
    "status": "in_progress",
    "status_label": "У ремонті",
    "vehicle": {"make": "Toyota", "model": "Camry", "plate": "AA 1234 BC"},
    "progress": 0.6,
    "eta": "${iso(const Duration(hours: 3))}",
    "total_uah": 2850,
    "timeline": [
      {"stage": "accepted", "label": "Прийнято", "at": "${iso(const Duration(hours: -4))}"},
      {"stage": "diagnostics", "label": "Діагностика", "at": "${iso(const Duration(hours: -3))}"},
      {"stage": "in_progress", "label": "У ремонті", "at": "${iso(const Duration(hours: -2))}"}
    ]
  },
  {
    "id": "4522",
    "title": "Діагностика двигуна",
    "status": "pending_confirmation",
    "status_label": "Очікує підтвердження",
    "vehicle": {"make": "Toyota", "model": "Camry", "plate": "AA 1234 BC"},
    "scheduled_for": "${iso(const Duration(days: 1))}"
  }
]
''';
}
