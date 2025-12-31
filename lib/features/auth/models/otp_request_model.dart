class OtpRequestModel {
  final String phone;
  final String otp;

  OtpRequestModel({
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
    };
  }
}

