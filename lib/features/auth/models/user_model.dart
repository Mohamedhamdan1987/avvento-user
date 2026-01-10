class UserModel {
  final String id;
  final String username;
  final String phone;
  final String role; // 'client' or 'delivery'
  final bool? isPhoneVerified;
  final String? email;

  UserModel({
    required this.id,
    required this.username,
    required this.phone,
    required this.role,
    this.isPhoneVerified,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Map 'delivery' role to 'delivery' as requested
    // Map 'user' role to 'client' as requested
    String role = json['role'] as String? ?? 'user';

    String mappedType = (role == 'delivery' || role == 'driver') ? 'delivery' : 'client';

    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      username: json['username'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: mappedType,
      isPhoneVerified: json['isVerified'] as bool? ?? json['is_phone_verified'] as bool?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone': phone,
      'role': role,
      if (isPhoneVerified != null) 'is_phone_verified': isPhoneVerified,
      if (email != null) 'email': email,
    };
  }
}

