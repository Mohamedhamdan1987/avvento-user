class ResetPasswordRequestModel {
  final String username;
  final String otp;
  final String newPassword;

  ResetPasswordRequestModel({
    required this.username,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'otp': otp,
      'newPassword': newPassword,
    };
  }
}

