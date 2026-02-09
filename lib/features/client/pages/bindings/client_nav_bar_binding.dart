import 'package:get/get.dart';
import '../controllers/client_nav_bar_controller.dart';
import '../../orders/controllers/orders_controller.dart';

class ClientNavBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientNavBarController());
    Get.lazyPut(() => OrdersController());
  }
}
