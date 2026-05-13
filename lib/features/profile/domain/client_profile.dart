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

  ClientProfile copyWith({String? name, String? email}) => ClientProfile(
        phone: phone,
        name: name ?? this.name,
        email: email ?? this.email,
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
