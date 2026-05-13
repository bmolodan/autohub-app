import 'dart:convert';

import '../../domain/client_profile.dart';

/// JSON ↔ ClientProfile. Single source of truth for the wire/storage shape;
/// any future HTTP adapter shares the same codec.

String encodeClientProfile(ClientProfile profile) => jsonEncode({
      'phone': profile.phone,
      'name': profile.name,
      'email': profile.email,
    });

/// Returns null when [raw] is malformed (any decode error). Caller decides
/// whether to surface the parse failure or treat the row as absent.
ClientProfile? tryDecodeClientProfile(String raw) {
  try {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return ClientProfile(
      phone: m['phone'] as String,
      name: m['name'] as String,
      email: m['email'] as String?,
    );
  } on Object catch (_) {
    return null;
  }
}
