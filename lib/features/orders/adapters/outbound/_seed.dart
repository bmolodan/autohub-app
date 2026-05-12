/// Goes away once a real backend is wired in.
const kActiveOrdersSeedJson = '''
[
  {
    "id": "4521",
    "title": "Заміна гальмівних колодок",
    "status": "in_progress",
    "status_label": "У ремонті",
    "vehicle": {"make": "Toyota", "model": "Camry", "plate": "AA 1234 BC"},
    "progress": 0.6,
    "eta": "2026-05-13T14:00:00+03:00",
    "total_uah": 2850,
    "timeline": [
      {"stage": "accepted", "label": "Прийнято", "at": "2026-05-13T10:24:00+03:00"},
      {"stage": "diagnostics", "label": "Діагностика", "at": "2026-05-13T11:05:00+03:00"},
      {"stage": "in_progress", "label": "У ремонті", "at": "2026-05-13T12:30:00+03:00"}
    ]
  },
  {
    "id": "4522",
    "title": "Діагностика двигуна",
    "status": "pending_confirmation",
    "status_label": "Очікує підтвердження",
    "vehicle": {"make": "Toyota", "model": "Camry", "plate": "AA 1234 BC"},
    "scheduled_for": "2026-05-14T16:00:00+03:00"
  }
]
''';
