/// Authenticated session — what the app remembers about the signed-in user.
class Session {
  const Session({
    required this.phone,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.createdAt,
  });

  final String phone;
  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime createdAt;

  Session copyWith({
    String? phone,
    String? accessToken,
    String? refreshToken,
    DateTime? accessExpiresAt,
    DateTime? createdAt,
  }) =>
      Session(
        phone: phone ?? this.phone,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        accessExpiresAt: accessExpiresAt ?? this.accessExpiresAt,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      other is Session &&
      other.phone == phone &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken &&
      other.accessExpiresAt == accessExpiresAt &&
      other.createdAt == createdAt;

  @override
  int get hashCode =>
      Object.hash(phone, accessToken, refreshToken, accessExpiresAt, createdAt);
}
