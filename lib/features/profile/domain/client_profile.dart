/// User-side identity captured during onboarding. The phone number comes
/// from the OTP session; name is required, email is optional.
class ClientProfile {
  const ClientProfile({
    required this.phone,
    required this.name,
    this.email,
  });

  final String phone;
  final String name;
  final String? email;

  static const Object _keep = Object();

  /// Email is nullable, so the standard `field ?? this.field` pattern can't
  /// clear it. Pass [email] explicitly as `null` to clear; omit (default
  /// sentinel) to keep the current value.
  ClientProfile copyWith({String? name, Object? email = _keep}) =>
      ClientProfile(
        phone: phone,
        name: name ?? this.name,
        email: identical(email, _keep) ? this.email : email as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is ClientProfile &&
      other.phone == phone &&
      other.name == name &&
      other.email == email;

  @override
  int get hashCode => Object.hash(phone, name, email);

  @override
  String toString() =>
      'ClientProfile(phone: $phone, name: $name, email: $email)';
}
