import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';
import 'restaurant_cart_details_page.dart';

class CartListPage extends StatelessWidget {
  const CartListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('السلة'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.carts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80.r, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'سلة التسوق فارغة',
                    style: const TextStyle().textColorBold(fontSize: 18.sp),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => controller.refreshCarts(),
            child: ListView.separated(
              padding: EdgeInsets.all(24.w),
              itemCount: controller.carts.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final cart = controller.carts[index];
                return _buildRestaurantCartCard(context, cart);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRestaurantCartCard(BuildContext context, RestaurantCart cart) {
    return GestureDetector(
      onTap: () {
        Get.to(() => RestaurantCartDetailsPage(cart: cart));
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            // Restaurant Logo
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: cart.restaurant.logo != null
                    ? CachedNetworkImage(
                        imageUrl: cart.restaurant.logo!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.restaurant),
              ),
            ),
            SizedBox(width: 16.w),
            // Cart Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cart.restaurant.name,
                    style: const TextStyle().textColorBold(fontSize: 16.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${cart.items.length} أصناف',
                    style: const TextStyle().textColorMedium(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Total Price & Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${cart.totalPrice.toStringAsFixed(0)} د.ل',
                  style: const TextStyle().textColorBold(
                    fontSize: 16.sp,
                    color: Color(0xFF7F22FE),
                  ),
                ),
                SizedBox(height: 4.h),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
