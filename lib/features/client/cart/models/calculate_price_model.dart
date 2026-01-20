class CalculatePriceResponse {
  final double subtotal;
  final double deliveryFee;
  final DeliveryFeeDetails? deliveryFeeDetails;
  final double tax;
  final double totalPrice;
  final List<CalculatedItem>? items;
  final String? paymentMethod;
  final double? walletBalance;
  final bool? canPayWithWallet;
  final bool? insufficientBalance;

  CalculatePriceResponse({
    required this.subtotal,
    required this.deliveryFee,
    this.deliveryFeeDetails,
    required this.tax,
    required this.totalPrice,
    this.items,
    this.paymentMethod,
    this.walletBalance,
    this.canPayWithWallet,
    this.insufficientBalance,
  });

  factory CalculatePriceResponse.fromJson(Map<String, dynamic> json) {
    return CalculatePriceResponse(
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      deliveryFeeDetails: json['deliveryFeeDetails'] != null
          ? DeliveryFeeDetails.fromJson(json['deliveryFeeDetails'])
          : null,
      tax: (json['tax'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      items: (json['items'] as List?)
          ?.map((e) => CalculatedItem.fromJson(e))
          .toList(),
      paymentMethod: json['paymentMethod'],
      walletBalance: json['walletBalance'] != null ? (json['walletBalance'] as num).toDouble() : null,
      canPayWithWallet: json['canPayWithWallet'],
      insufficientBalance: json['insufficientBalance'],
    );
  }
}

class DeliveryFeeDetails {
  final double dayPrice;
  final double nightPrice;
  final bool isNight;
  final double distance;

  DeliveryFeeDetails({
    required this.dayPrice,
    required this.nightPrice,
    required this.isNight,
    required this.distance,
  });

  factory DeliveryFeeDetails.fromJson(Map<String, dynamic> json) {
    return DeliveryFeeDetails(
      dayPrice: (json['dayPrice'] as num).toDouble(),
      nightPrice: (json['nightPrice'] as num).toDouble(),
      isNight: json['isNight'] ?? false,
      distance: (json['distance'] as num).toDouble(),
    );
  }
}

class CalculatedItem {
  final String? item;
  final String? drink;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  CalculatedItem({
    this.item,
    this.drink,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  factory CalculatedItem.fromJson(Map<String, dynamic> json) {
    return CalculatedItem(
      item: json['item'],
      drink: json['drink'],
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      notes: json['notes'],
    );
  }
}
