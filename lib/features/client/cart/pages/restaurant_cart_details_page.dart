import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/features/client/restaurants/pages/restaurant_details_screen.dart';
import 'package:avvento/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';

class RestaurantCartDetailsPage extends StatefulWidget {
  final RestaurantCartResponse cart;
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
      controller.fetchRestaurantCart(widget.cart.restaurant.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: CustomAppBar(
        title: 'السلة',
        backgroundColor: const Color(0xFFF9FAFB),
        actions: [
          CustomIconButtonApp(
            onTap: () {
              Get.defaultDialog(
                title: 'مسح السلة',
                middleText: 'هل أنت متأكد من مسح جميع المنتجات من السلة؟',
                textConfirm: 'مسح',
                textCancel: 'إلغاء',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  controller.clearCart(widget.cart.restaurant.id!);
                },
              );
            },
            childWidget: Icon(Icons.delete_sweep_outlined, color: Colors.red, size: 24.r),
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 13.h),
                      // Restaurant Info Header
                      _buildRestaurantHeader(currentCart),
                      SizedBox(height: 13.h),
                      // Cart Items
                      ...currentCart.items.map((item) => Padding(
                            padding: EdgeInsets.only(bottom: 13.h),
                            child: _buildCartItemCard(item, currentCart.items.indexOf(item), currentCart),
                          )),
                      SizedBox(height: 13.h),
                      // Add Items Button
                      _buildAddItemsButton(),
                      SizedBox(height: 16.h),
                      // Suggested Drinks Section
                      _buildSuggestedDrinksSection(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              _buildBottomSummary(currentCart),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRestaurantHeader(RestaurantCartResponse currentCart) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.76.w, vertical: 0.76.h),
      height: 73.51.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 0.761,
        ),
      ),
      child: Row(
        children: [
          // Restaurant Logo (Right in RTL - was Right in Figma)
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(
                color: const Color(0xFFF3F4F6),
                width: 0.761,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.r),
              child: currentCart.restaurant.logo != null
                  ? CachedNetworkImage(
                      imageUrl: currentCart.restaurant.logo!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.restaurant, color: Colors.grey),
            ),
          ),
          SizedBox(width: 12.w),
          // Restaurant Info (Middle)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentCart.restaurant.name!,
                  style: const TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: Color(0xFF101828),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    SvgIcon(
                      iconName: 'assets/svg/client/star_filled.svg',
                      width: 12.w,
                      height: 12.h,
                      color: const Color(0xFFFBBF24),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '(4808) 4.8',
                      style: const TextStyle().textColorNormal(
                        fontSize: 12.sp,
                        color: Color(0xFF99A1AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Back Arrow Button (Left in RTL - was Left in Figma)
          CustomIconButtonApp(
            width: 16.w,
            height: 16.h,
            onTap: () => Navigator.pop(context),
            childWidget: Transform.rotate(
              angle: 3.14159, // 180 degrees
              child: SvgIcon(
                iconName: 'assets/svg/arrow-right.svg',
                width: 16.w,
                height: 16.h,
                color: const Color(0xFFD1D5DC),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem cartItem, int index, RestaurantCartResponse currentCart) {
    return Container(
      height: 125.49.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 0.761,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delete Button (Right in RTL - was Right in Figma)
              Padding(
                padding: EdgeInsetsDirectional.only(top: 16.h, start: 16.w),
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
                        controller.removeItem(currentCart.restaurant.id!, index);
                        Get.back();
                      },
                    );
                  },
                  child: SvgIcon(
                    iconName: 'assets/svg/cart/delete.svg',
                    width: 16.w,
                    height: 16.h,
                    // color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Item Details (Middle)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.item.name,
                        style: const TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Color(0xFF101828),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${cartItem.totalPrice.toStringAsFixed(0)} د.ل',
                        style: const TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Color(0xFF101828),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Quantity controls
                      Obx(() {
                        if (controller.updatingItemIndex == index) {
                          return SizedBox(
                            width: 120.w,
                            height: 36.h,
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
                          width: 120.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 0.761,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Plus Button
                              GestureDetector(
                                onTap: () {
                                  controller.updateQuantity(
                                    restaurantId: currentCart.restaurant.id!,
                                    itemIndex: index,
                                    quantity: cartItem.quantity + 1,
                                    notes: cartItem.notes,
                                  );
                                },
                                child: Container(
                                  width: 28.w,
                                  height: 34.48.h,
                                  alignment: Alignment.center,
                                  child: SvgIcon(
                                    iconName: 'assets/svg/client/restaurant_details/plus_icon.svg',
                                    width: 16.w,
                                    height: 16.h,
                                    color: const Color(0xFF101828),
                                  ),
                                ),
                              ),

                              // Quantity
                              Text(
                                '${cartItem.quantity}',
                                style: const TextStyle().textColorBold(
                                  fontSize: 14.sp,
                                  color: Color(0xFF101828),
                                ),
                              ),
                              // Minus Button
                              GestureDetector(
                                onTap: () {
                                  if (cartItem.quantity > 1) {
                                    controller.updateQuantity(
                                      restaurantId: currentCart.restaurant.id!,
                                      itemIndex: index,
                                      quantity: cartItem.quantity - 1,
                                      notes: cartItem.notes,
                                    );
                                  }
                                  else {
                                    Get.defaultDialog(
                                      title: 'حذف المنتج',
                                      middleText: 'هل أنت متأكد من حذف هذا المنتج من السلة؟',
                                      textConfirm: 'حذف',
                                      textCancel: 'إلغاء',
                                      confirmTextColor: Colors.white,
                                      buttonColor: Colors.red,
                                      onConfirm: () {
                                        controller.removeItem(currentCart.restaurant.id!, index);
                                        Get.back();
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  width: 28.w,
                                  height: 34.48.h,
                                  alignment: Alignment.center,
                                  child: SvgIcon(
                                    iconName: cartItem.quantity > 1
                                        ? 'assets/svg/client/restaurant_details/minus_icon.svg'
                                        : 'assets/svg/cart/delete.svg',
                                    width: 16.w,
                                    height: 16.h,
                                    color: const Color(0xFF101828),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Item Image (Left in RTL - was Left in Figma)
              Padding(
                padding: EdgeInsetsDirectional.only(top: 22.h, end: 16.w),
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: cartItem.item.image != null
                        ? CachedNetworkImage(
                            imageUrl: cartItem.item.image!,
                            fit: BoxFit.cover,
                          )
                        : Container(color: Colors.grey[200]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemsButton() {
    return GestureDetector(
      onTap: () {
        // Navigate to restaurant menu or add items
        // Get.back();
        Get.to(() => RestaurantDetailsScreen(restaurantId: widget.cart.restaurant.restaurantId!!));

      },
      child: Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: const Color(0xFF7F22FE).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(
              iconName: 'assets/svg/client/restaurant_details/plus_icon.svg',
              width: 16.w,
              height: 16.h,
              color: const Color(0xFF7F22FE),
            ),
            SizedBox(width: 8.w),
            Text(
              'إضافة عناصر',
              style: const TextStyle().textColorBold(
                fontSize: 14.sp,
                color: Color(0xFF7F22FE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedDrinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أضف مشروبات',
          style: const TextStyle().textColorBold(
            fontSize: 14.sp,
            color: Color(0xFF101828),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 157.49.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Placeholder - replace with actual drinks
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              return _buildDrinkCard();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDrinkCard() {
    return Container(
      width: 140.w,
      height: 149.49.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 0.761,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 12.h),
              // Drink Image
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: Container(
                    color: Colors.grey[200],
                    // Placeholder - replace with actual image
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              // Drink Name
              Text(
                'جرين كولا موهيتو',
                style: const TextStyle().textColorBold(
                  fontSize: 12.sp,
                  color: Color(0xFF101828),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              // Drink Price
              Text(
                '4 د.ل',
                style: const TextStyle().textColorNormal(
                  fontSize: 12.sp,
                  color: Color(0xFF6A7282),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          // Add Button
          PositionedDirectional(
            start: 29.24.w,
            top: 64.h,
            child: GestureDetector(
              onTap: () {
                // Add drink to cart
              },
              child: Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 0.761,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgIcon(
                    iconName: 'assets/svg/client/restaurant_details/plus_icon.svg',
                    width: 16.w,
                    height: 16.h,
                    color: const Color(0xFF7F22FE),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(RestaurantCartResponse currentCart) {
    return Container(
      padding: EdgeInsets.only(top: 16.h, left: 24.w, right: 24.w, bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFF3F4F6),
            width: 0.761,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Invoice Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chevron Icon (Left in RTL)
              CustomIconButtonApp(
                width: 20.w,
                height: 20.h,
                onTap: () {
                  // Expand/collapse invoice details
                },
                childWidget: SvgIcon(
                  iconName: 'assets/svg/cart/arrow-top.svg',
                  width: 20.w,
                  height: 20.h,
                  color: const Color(0xFF101828),
                ),
              ),
              // Invoice Text (Right in RTL)
              Text(
                'الفاتورة',
                style: const TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Continue Button
          Obx(() => GestureDetector(
                onTap: controller.isLoading
                    ? null
                    : () {
                        Get.toNamed(AppRoutes.checkout, arguments: currentCart);
                      },
                child: Container(
                  height: 56.h,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4D179A),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E51FF).withOpacity(0.19),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Continue Text (Right in RTL)
                      if (controller.isLoading)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      else
                        Text(
                          'استمرار',
                          style: const TextStyle().textColorBold(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      // Total Price (Left in RTL)
                      Text(
                        '${currentCart.totalPrice.toStringAsFixed(1)} د.ل',
                        style: const TextStyle().textColorBold(
                          fontSize: 18.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
