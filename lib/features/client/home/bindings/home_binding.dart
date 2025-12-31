import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure HomeController is created
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    } else {
      // If controller exists, refresh data to ensure it's loaded
      final controller = Get.find<HomeController>();
      if (controller.isLoading == false ) {

      }
    }
  }
}
