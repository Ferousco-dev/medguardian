class UserAccount {
  const UserAccount({
    required this.id,
    required this.fullName,
    required this.email,
    this.twinId,
  });

  final String id;
  final String fullName;
  final String email;

  final String? twinId;

  bool get hasTwin => twinId != null && twinId!.isNotEmpty;

  String get initials {
    final List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      final String only = parts.first;
      return (only.length >= 2 ? only.substring(0, 2) : only).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      twinId: json['twin_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'full_name': fullName,
    'email': email,
    'twin_id': twinId,
  };

  UserAccount copyWith({String? fullName, String? twinId}) {
    return UserAccount(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      twinId: twinId ?? this.twinId,
    );
  }
}
