import 'user_model.dart';

class LoginResponseModel {
  final UserModel user;
  final String? token;

  LoginResponseModel({
    required this.user,
    this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      if (token != null) 'token': token,
    };
  }
}

