class RegisterRequestModel {
  final String username;
  final String name;
  final String phone;
  final String email;
  final String password;
  // final String role;
  final String? address;
  final double? lat;
  final double? long;
  final String? locationType;
  final String? notes;

  RegisterRequestModel({
    required this.username,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    // this.role = 'user',
    this.address,
    this.lat,
    this.long,
    this.locationType,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      // 'role': role,
      if (address != null && address!.trim().isNotEmpty) 'address': address,
      if (lat != null) 'lat': lat,
      if (long != null) 'long': long,
      if (locationType != null && locationType!.trim().isNotEmpty)
        'locationType': locationType,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    };
  }
}

