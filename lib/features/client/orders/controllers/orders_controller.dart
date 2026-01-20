import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
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
        o.status != 'completed' && o.status != 'cancelled' && o.status != 'delivered' && o.status != 'delivery_received'
      ).toList());
      
      previousOrders.assignAll(response.orders.where((o) => 
        o.status == 'completed' || o.status == 'cancelled' || o.status == 'delivered' || o.status == 'delivery_received'
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

  Future<bool> rateRestaurant({
    required String restaurantId,
    required int rating,
    required String comment,
    required String orderId,
  }) async {
    try {
      isLoading.value = true;
      await _ordersService.rateRestaurant(
        restaurantId: restaurantId,
        rating: rating,
        comment: comment,
        orderId: orderId,
      );
      Get.snackbar(
        'نجاح', 
        'شكراً لتقييمك!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(15),
        borderRadius: 10,
        icon: const Icon(Icons.check_circle, color: AppColors.white),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ', 
        'فشل في إرسال التقييم',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(15),
        borderRadius: 10,
        icon: const Icon(Icons.error, color: AppColors.white),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> rateDriver({
    required String orderId,
    required int rating,
    required String comment,
  }) async {
    try {
      isLoading.value = true;
      await _ordersService.rateDriver(
        orderId: orderId,
        rating: rating,
        comment: comment,
      );
      Get.snackbar(
        'نجاح', 
        'شكراً لتقييمك للسائق!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(15),
        borderRadius: 10,
        icon: const Icon(Icons.check_circle, color: AppColors.white),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ', 
        'فشل في إرسال تقييم السائق',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        margin: const EdgeInsets.all(15),
        borderRadius: 10,
        icon: const Icon(Icons.error, color: AppColors.white),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
