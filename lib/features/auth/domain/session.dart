/// Authenticated session — what the app remembers about the signed-in user.
class Session {
  const Session({required this.phone, required this.createdAt});

  final String phone;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is Session && other.phone == phone && other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(phone, createdAt);
}
