class ForgotPasswordRequestModel {
  final String userName;

  ForgotPasswordRequestModel({
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': userName,
    };
  }
}

