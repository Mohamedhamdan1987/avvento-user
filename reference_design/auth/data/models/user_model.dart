import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    required super.phone,
    required super.role,
    required super.isVerified,
    required super.isActive,
    super.address,
    super.lat,
    super.long,
    super.backgroundImage,
    super.logo,
    super.ownerName,
    super.description,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      address: json['address'],
      lat: json['lat'] != null ? double.parse(json['lat'].toString()) : null,
      long: json['long'] != null ? double.parse(json['long'].toString()) : null,
      backgroundImage: json['backgroundImage'],
      logo: json['logo'],
      ownerName: json['ownerName'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
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

  // For backward compatibility
  String get type => role;
}

