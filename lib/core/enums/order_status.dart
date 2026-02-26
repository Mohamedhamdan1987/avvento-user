enum OrderStatus {
  deliveryTake('delivery_take'),
  pending('pending'),
  preparing('preparing'),
  deliveryReceived('delivery_received'),
  onTheWay('on_the_way'),
  awaitingDelivery('awaiting_delivery'),
  delivered('delivered'),
  cancelled('cancelled');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == status.toLowerCase(),
      orElse: () => OrderStatus.deliveryTake,
    );
  }

  String get label {

    switch (this) {
      case OrderStatus.deliveryTake:
        return 'بانتظار أخذ السائق للطلب';
      case OrderStatus.pending:
        return 'بانتظار القبول (مطعم أو متجر)';
      case OrderStatus.preparing:
        return 'جاري التحضير';
      case OrderStatus.onTheWay:
        return 'في الطريق اليك';
      case OrderStatus.awaitingDelivery:
        return 'في انتظار التسليم';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.deliveryReceived:
        return 'استلم المستخدم الطلب';
      case OrderStatus.cancelled:
        return 'تم الإلغاء';
    }
  }
}
