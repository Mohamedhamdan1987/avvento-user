class AddressModel {
  final String id;
  final String user;
  final String label;
  final String address;
  final double lat;
  final double long;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    required this.user,
    required this.label,
    required this.address,
    required this.lat,
    required this.long,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      label: json['label'] ?? '',
      address: json['address'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      long: (json['long'] as num).toDouble(),
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'address': address,
      'lat': lat,
      'long': long,
    };
  }
}
