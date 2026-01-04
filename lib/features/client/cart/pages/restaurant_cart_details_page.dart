import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';

class RestaurantCartDetailsPage extends StatefulWidget {
  final RestaurantCart cart;
  const RestaurantCartDetailsPage({super.key, required this.cart});

  @override
  State<RestaurantCartDetailsPage> createState() => _RestaurantCartDetailsPageState();
}

class _RestaurantCartDetailsPageState extends State<RestaurantCartDetailsPage> {
  final CartController controller = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchRestaurantCart(widget.cart.restaurant.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('سلة ${widget.cart.restaurant.name}'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomIconButtonApp(
          onTap: () => Get.back(),
          childWidget: SvgIcon(
            iconName: 'assets/svg/arrow-right.svg',
            width: 20.w,
            height: 20.h,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.defaultDialog(
                title: 'مسح السلة',
                middleText: 'هل أنت متأكد من مسح جميع المنتجات من السلة؟',
                textConfirm: 'مسح',
                textCancel: 'إلغاء',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  controller.clearCart(widget.cart.restaurant.id);
                },
              );
            },
            icon: Icon(Icons.delete_sweep_outlined, color: Colors.red, size: 24.r),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoading && controller.detailedCart == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentCart = controller.detailedCart;
          if (currentCart == null) {
            return const Center(child: Text('فشل تحميل البيانات'));
          }

          if (currentCart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.remove_shopping_cart, size: 80.r, color: Colors.grey),
                   SizedBox(height: 16.h),
                   Text('السلة فارغة', style: const TextStyle().textColorBold(fontSize: 18.sp)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(24.w),
                  itemCount: currentCart.items.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final item = currentCart.items[index];
                    return _buildCartItemCard(item, index, currentCart);
                  },
                ),
              ),
              _buildBottomSummary(currentCart),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem cartItem, int index, RestaurantCart currentCart) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: cartItem.item.image != null
                      ? CachedNetworkImage(
                          imageUrl: cartItem.item.image!,
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey[200]),
                ),
              ),
              SizedBox(width: 12.w),
              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.item.name,
                      style: const TextStyle().textColorBold(fontSize: 14.sp),
                    ),
                    if (cartItem.selectedVariations.isNotEmpty)
                      Text(
                        'الحجم: ${cartItem.selectedVariations.join(', ')}',
                        style: const TextStyle().textColorMedium(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    if (cartItem.selectedAddOns.isNotEmpty)
                      Text(
                        'الإضافات: ${cartItem.selectedAddOns.join(', ')}',
                        style: const TextStyle().textColorMedium(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    if (cartItem.notes.isNotEmpty)
                      Text(
                        'ملاحظات: ${cartItem.notes}',
                        style: const TextStyle().textColorMedium(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${cartItem.totalPrice.toStringAsFixed(0)} د.ل',
                          style: const TextStyle().textColorBold(
                            fontSize: 14.sp,
                            color: Color(0xFF7F22FE),
                          ),
                        ),
                        // Quantity controls
                        Obx(() {
                          if (controller.updatingItemIndex == index) {
                            return SizedBox(
                              width: 60.w,
                              height: 24.h,
                              child: Center(
                                child: SizedBox(
                                  width: 16.r,
                                  height: 16.r,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF7F22FE),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (cartItem.quantity > 1) {
                                      controller.updateQuantity(
                                        restaurantId: currentCart.restaurant.id,
                                        itemIndex: index,
                                        quantity: cartItem.quantity - 1,
                                        notes: cartItem.notes,
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(4.w),
                                    child: Icon(Icons.remove, size: 16.r, color: Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Text(
                                    '${cartItem.quantity}',
                                    style: const TextStyle().textColorBold(fontSize: 14.sp),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    controller.updateQuantity(
                                      restaurantId: currentCart.restaurant.id,
                                      itemIndex: index,
                                      quantity: cartItem.quantity + 1,
                                      notes: cartItem.notes,
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(4.w),
                                    child: Icon(Icons.add, size: 16.r, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Delete Button
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                Get.defaultDialog(
                  title: 'حذف المنتج',
                  middleText: 'هل أنت متأكد من حذف هذا المنتج من السلة؟',
                  textConfirm: 'حذف',
                  textCancel: 'إلغاء',
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () {
                    controller.removeItem(currentCart.restaurant.id, index);
                    Get.back();
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline, size: 18.r, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(RestaurantCart currentCart) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع الكلي',
                style: const TextStyle().textColorBold(fontSize: 18.sp),
              ),
              Text(
                '${currentCart.totalPrice.toStringAsFixed(0)} د.ل',
                style: const TextStyle().textColorBold(
                  fontSize: 20.sp,
                  color: Color(0xFF7F22FE),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          CustomButtonApp(
            text: 'إتمام الطلب',
            onTap: () {
              // Handle checkout
            },
          ),
        ],
      ),
    );
  }
}
