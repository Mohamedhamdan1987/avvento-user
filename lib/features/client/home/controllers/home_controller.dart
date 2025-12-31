import 'package:get/get.dart';


class HomeController extends GetxController {
  // Observable state
  final RxBool _isLoading = false.obs;
  final RxInt _currentPromoPage = 0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  int get currentPromoPage => _currentPromoPage.value;

  // Setters
  void setCurrentPromoPage(int index) => _currentPromoPage.value = index;
}
