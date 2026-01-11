import 'package:avvento/features/client/address/controllers/address_controller.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
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
