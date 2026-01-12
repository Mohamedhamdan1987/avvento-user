class UserProfileModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String address;
  final double? lat;
  final double? long;
  final String? deliveryStatus;
  final String? logo;
  final String? backgroundImage;
  final String? ownerName;
  final String? description;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    this.lat,
    this.long,
    this.deliveryStatus,
    this.logo,
    this.backgroundImage,
    this.ownerName,
    this.description,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      long: (json['long'] as num?)?.toDouble(),
      deliveryStatus: json['deliveryStatus'],
      logo: json['logo'],
      backgroundImage: json['backgroundImage'],
      ownerName: json['ownerName'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'lat': lat?.toString(),
      'long': long?.toString(),
      'ownerName': ownerName,
      'description': description,
    };
  }
}
