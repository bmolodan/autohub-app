/// HH:mm in the device's local timezone.
String formatHm(DateTime dt) {
  final local = dt.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// dd.MM · HH:mm in the device's local timezone.
String formatDdMmHm(DateTime dt) {
  final local = dt.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final mo = local.month.toString().padLeft(2, '0');
  return '$d.$mo · ${formatHm(local)}';
}
