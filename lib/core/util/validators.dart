// Shared form-validator helpers. Localized error strings are passed in
// by the caller so the util stays platform-free (no Flutter imports).

/// Returns [requiredMessage] when [value] is null/blank, else null.
String? requireNonEmpty(String? value, String requiredMessage) {
  if (value == null || value.trim().isEmpty) return requiredMessage;
  return null;
}

/// Pragmatic email regex — RFC-compliant is overkill for a UI nudge.
final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
