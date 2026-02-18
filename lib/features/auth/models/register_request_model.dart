class RegisterRequestModel {
  final String username;
  final String name;
  final String phone;
  final String email;
  final String password;

  RegisterRequestModel({
    required this.username,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
    };
  }
}

