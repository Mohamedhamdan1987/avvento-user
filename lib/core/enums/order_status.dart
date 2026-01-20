import 'package:avvento/core/utils/logger.dart';

enum OrderStatus {
  pendingRestaurant('pending_restaurant'),
  confirmed('confirmed'),
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
      orElse: () => OrderStatus.pendingRestaurant,
    );
  }

  String get label {

    switch (this) {
      case OrderStatus.pendingRestaurant:
        return 'بانتظار قبول المطعم';
      case OrderStatus.confirmed:
        return 'تم تاكيد الطلب';
      case OrderStatus.preparing:
        return 'جاري التحضير';
      case OrderStatus.onTheWay:
        return 'في الطريق اليك';
      case OrderStatus.awaitingDelivery:
        return 'في انتظار التسليم';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.deliveryReceived:
        return 'تم استلام الطلب';
      case OrderStatus.cancelled:
        return 'تم الإلغاء';
    }
  }
}
