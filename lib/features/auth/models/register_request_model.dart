class RegisterRequestModel {
  final String username;
  final String password;
  final String phone;
  final String language;

  RegisterRequestModel({
    required this.username,
    required this.password,
    required this.phone,
    this.language = 'ar',
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'phone': phone,
      'language': language,
    };
  }
}

