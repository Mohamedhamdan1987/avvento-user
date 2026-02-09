import 'package:get/get.dart';

class ClientNavBarController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void goToOrders() {
    currentIndex.value = 1;
  }

  void setIndex(int index) {
    currentIndex.value = index;
  }
}
