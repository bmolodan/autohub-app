import 'dart:convert';

/// Reads the `exp` claim from a JWT and returns it as a UTC DateTime.
/// Signature is NOT validated client-side — that's the server's job.
DateTime jwtExpiresAt(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) {
    throw const FormatException('not a JWT (expected 3 segments)');
  }
  final payload = jsonDecode(
    utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
  ) as Map<String, dynamic>;
  final exp = payload['exp'];
  if (exp is! int) throw const FormatException('JWT missing exp claim');
  return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
}
