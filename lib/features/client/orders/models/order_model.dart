class OrderItem {
  final String itemId;
  final int quantity;
  final List<String> selectedVariations;
  final List<String> selectedAddOns;
  final String notes;
  final double unitPrice;
  final double totalPrice;
  final String id;

  OrderItem({
    required this.itemId,
    required this.quantity,
    required this.selectedVariations,
    required this.selectedAddOns,
    required this.notes,
    required this.unitPrice,
    required this.totalPrice,
    required this.id,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['item'] as String,
      quantity: json['quantity'] as int,
      selectedVariations: List<String>.from(json['selectedVariations'] ?? []),
      selectedAddOns: List<String>.from(json['selectedAddOns'] ?? []),
      notes: json['notes'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      id: json['_id'] as String,
    );
  }
}

class OrderRestaurant {
  final String id;
  final String name;
  final String? logo;

  OrderRestaurant({
    required this.id,
    required this.name,
    this.logo,
  });

  factory OrderRestaurant.fromJson(Map<String, dynamic> json) {
    return OrderRestaurant(
      id: json['_id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final OrderRestaurant restaurant;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double totalPrice;
  final String status;
  final String deliveryAddress;
  final double deliveryLat;
  final double deliveryLong;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.restaurant,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.totalPrice,
    required this.status,
    required this.deliveryAddress,
    required this.deliveryLat,
    required this.deliveryLong,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] as String,
      userId: json['user'] as String,
      restaurant: OrderRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      deliveryLat: (json['deliveryLat'] as num).toDouble(),
      deliveryLong: (json['deliveryLong'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class OrdersResponse {
  final List<OrderModel> orders;
  final int total;
  final int page;
  final int limit;

  OrdersResponse({
    required this.orders,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      orders: (json['orders'] as List<dynamic>)
          .map((o) => OrderModel.fromJson(o as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
    );
  }
}
