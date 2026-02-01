import 'package:avvento/features/client/address/controllers/address_controller.dart';
import 'package:get/get.dart';
import '../../../../core/services/socket_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure SocketService is created for real-time notifications
    if (!Get.isRegistered<SocketService>()) {
      Get.put(SocketService(), permanent: true);
    }

    // Ensure AddressController is created
    if (!Get.isRegistered<AddressController>()) {
      Get.put(AddressController(), permanent: true);
    }

    // Ensure HomeController is created
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }
  }
}
