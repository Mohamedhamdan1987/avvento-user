import 'package:get/get.dart';
import '../controllers/markets_controller.dart';
import '../controllers/market_cart_controller.dart';

class MarketsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarketsController>(
      () => MarketsController(),
    );
    Get.lazyPut<MarketCartController>(
      () => MarketCartController(),
    );
  }
}
