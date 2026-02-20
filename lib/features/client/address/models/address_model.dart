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
    final latRaw = json['lat'];
    final longRaw = json['long'];
    return AddressModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      lat: (latRaw is num) ? latRaw.toDouble() : double.tryParse(latRaw?.toString() ?? '') ?? 0.0,
      long: (longRaw is num) ? longRaw.toDouble() : double.tryParse(longRaw?.toString() ?? '') ?? 0.0,
      isActive: json['isActive'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
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
