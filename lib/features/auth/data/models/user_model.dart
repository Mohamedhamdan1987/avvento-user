import '../../../../core/utils/user_type.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserType userType;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.userType,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      userType: json['user_type'] == 'driver'
          ? UserType.driver
          : UserType.client,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': userType == UserType.driver ? 'driver' : 'client',
      'token': token,
    };
  }
}

