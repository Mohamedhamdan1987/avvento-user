class UserEntity {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String role;
  final bool isVerified;
  final bool isActive;
  final String? address;
  final double? lat;
  final double? long;
  final String? backgroundImage;
  final String? logo;
  final String? ownerName;
  final String? description;

  UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerified,
    required this.isActive,
    this.address,
    this.lat,
    this.long,
    this.backgroundImage,
    this.logo,
    this.ownerName,
    this.description,
  });

  // Helper getter for type (for backward compatibility)
  String get type => role;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      if (address != null) 'address': address,
      if (lat != null) 'lat': lat,
      if (long != null) 'long': long,
      if (backgroundImage != null) 'backgroundImage': backgroundImage,
      if (logo != null) 'logo': logo,
      if (ownerName != null) 'ownerName': ownerName,
      if (description != null) 'description': description,
    };
  }
}

