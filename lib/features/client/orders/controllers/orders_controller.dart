import 'package:get/get.dart';
import '../models/order_model.dart';
import '../services/orders_service.dart';

class OrdersController extends GetxController {
  final OrdersService _ordersService = OrdersService();

  final RxList<OrderModel> activeOrders = <OrderModel>[].obs;
  final RxList<OrderModel> previousOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final response = await _ordersService.getUserOrders();
      
      // Filter orders into active and previous
      // Assuming 'completed' and 'cancelled' are previous, everything else is active
      activeOrders.assignAll(response.orders.where((o) => 
        o.status != 'completed' && o.status != 'cancelled' && o.status != 'delivered'
      ).toList());
      
      previousOrders.assignAll(response.orders.where((o) => 
        o.status == 'completed' || o.status == 'cancelled' || o.status == 'delivered'
      ).toList());
      
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل الطلبات');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await fetchOrders();
  }
}
