class SettlementResponse {
  final List<SettlementOrder> orders;
  final int total;
  final int totalPages;
  final int page;
  final double pendingAmount;
  final int pendingCount;
  final double pendingCashCollected;
  final double settledAmount;
  final int settledCount;

  SettlementResponse({
    required this.orders,
    required this.total,
    required this.totalPages,
    required this.page,
    required this.pendingAmount,
    required this.pendingCount,
    required this.pendingCashCollected,
    required this.settledAmount,
    required this.settledCount,
  });

  factory SettlementResponse.fromJson(Map<String, dynamic> json) {
    return SettlementResponse(
      orders: (json['orders'] as List? ?? [])
          .map((e) => SettlementOrder.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      page: json['page'] ?? 1,
      pendingAmount: (json['pendingAmount'] ?? 0).toDouble(),
      pendingCount: json['pendingCount'] ?? 0,
      pendingCashCollected: (json['pendingCashCollected'] ?? 0).toDouble(),
      settledAmount: (json['settledAmount'] ?? 0).toDouble(),
      settledCount: json['settledCount'] ?? 0,
    );
  }
}

class SettlementOrder {
  final String id;
  final String orderType;
  final SettlementUser user;
  final SettlementRestaurant? restaurant;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String deliveryAddress;
  final String settlementStatus;
  final double settlementAmount;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  SettlementOrder({
    required this.id,
    required this.orderType,
    required this.user,
    this.restaurant,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.settlementStatus,
    required this.settlementAmount,
    required this.createdAt,
    this.deliveredAt,
  });

  factory SettlementOrder.fromJson(Map<String, dynamic> json) {
    return SettlementOrder(
      id: json['_id'] ?? '',
      orderType: json['orderType'] ?? '',
      user: SettlementUser.fromJson(json['user'] ?? {}),
      restaurant: json['restaurant'] != null
          ? SettlementRestaurant.fromJson(json['restaurant'])
          : null,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      settlementStatus: json['settlementStatus'] ?? '',
      settlementAmount: (json['settlementAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
    );
  }
}

class SettlementUser {
  final String id;
  final String name;
  final String phone;

  SettlementUser({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory SettlementUser.fromJson(Map<String, dynamic> json) {
    return SettlementUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class SettlementRestaurant {
  final String id;
  final String name;
  final String logo;

  SettlementRestaurant({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory SettlementRestaurant.fromJson(Map<String, dynamic> json) {
    return SettlementRestaurant(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}
