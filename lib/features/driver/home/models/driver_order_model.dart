class DriverOrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String restaurantId;
  final String restaurantName;
  final PickupLocation pickupLocation;
  final DeliveryLocation deliveryLocation;
  final List<OrderItem> items;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final double? deliveryFee;
  final String? notes;

  DriverOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.restaurantId,
    required this.restaurantName,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.deliveryFee,
    this.notes,
  });

  factory DriverOrderModel.fromJson(Map<String, dynamic> json) {
    // Handle the nested user object
    final user = json['user'] as Map<String, dynamic>?;
    
    // Handle the nested restaurant object
    final restaurant = json['restaurant'] as Map<String, dynamic>?;

    return DriverOrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      // Map _id to orderNumber if orderNumber is missing in the new API
      orderNumber: json['orderNumber']?.toString() ?? json['_id']?.toString().substring(json['_id'].toString().length - 6).toUpperCase() ?? '',
      customerId: user?['_id']?.toString() ?? json['customerId']?.toString() ?? '',
      customerName: user?['name']?.toString() ?? user?['username']?.toString() ?? json['customerName']?.toString() ?? '',
      customerPhone: user?['phone']?.toString() ?? json['customerPhone']?.toString() ?? '',
      restaurantId: restaurant?['_id']?.toString() ?? json['restaurantId']?.toString() ?? '',
      restaurantName: restaurant?['name']?.toString() ?? json['restaurantName']?.toString() ?? '',
      pickupLocation: PickupLocation.fromJson(
        json['pickupLocation'] as Map<String, dynamic>? ?? restaurant?['location'] as Map<String, dynamic>? ?? {
          'address': restaurant?['address'] ?? '',
          'lat': restaurant?['lat'] ?? 0,
          'lng': restaurant?['lng'] ?? 0,
        },
      ),
      deliveryLocation: DeliveryLocation.fromJson(
        {
          'address': json['deliveryAddress'] ?? '',
          'lat': json['deliveryLat'] ?? 0,
          'lng': json['deliveryLong'] ?? 0,
        },
      ),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalPrice'] ?? json['totalAmount'] ?? json['total'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod']?.toString() ?? 'cash',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      deliveryFee: json['deliveryFee'] != null ? (json['deliveryFee'] as num).toDouble() : null,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'pickupLocation': pickupLocation.toJson(),
      'deliveryLocation': deliveryLocation.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (deliveryFee != null) 'deliveryFee': deliveryFee,
      if (notes != null) 'notes': notes,
    };
  }
}

class PickupLocation {
  final String address;
  final double latitude;
  final double longitude;

  PickupLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory PickupLocation.fromJson(Map<String, dynamic> json) {
    return PickupLocation(
      address: json['address']?.toString() ?? '',
      latitude: (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? json['long'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class DeliveryLocation {
  final String address;
  final double latitude;
  final double longitude;
  final String? label;

  DeliveryLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.label,
  });

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      address: json['address']?.toString() ?? '',
      latitude: (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? json['long'] ?? 0).toDouble(),
      label: json['label']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      if (label != null) 'label': label,
    };
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name']?.toString() ?? json['itemName']?.toString() ?? 'وجبة',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['unitPrice'] ?? json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}
