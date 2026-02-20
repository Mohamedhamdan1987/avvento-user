import 'package:avvento/core/utils/logger.dart' show cprint;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/show_snackbar.dart';
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
          o.status != 'completed' &&
          o.status != 'cancelled' &&
          o.status != 'delivered' &&
          o.status != 'delivery_received').toList());

      previousOrders.assignAll(response.orders.where((o) =>
          o.status == 'completed' ||
          o.status == 'cancelled' ||
          o.status == 'delivered' ||
          o.status == 'delivery_received').toList());
    } catch (e) {
      cprint('فشل في تحميل الطلبات: $e');
      showSnackBar(message: 'فشل في تحميل الطلبات', isError: true);
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
      showSnackBar(
        title: 'نجاح',
        message: 'شكراً لتقييمك!',
        isSuccess: true,
      );
      return true;
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'فشل في إرسال التقييم',
        isError: true,
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
      showSnackBar(
        title: 'نجاح',
        message: 'شكراً لتقييمك للسائق!',
        isSuccess: true,
      );
      return true;
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'فشل في إرسال تقييم السائق',
        isError: true,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
