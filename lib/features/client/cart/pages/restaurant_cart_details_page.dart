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
import '../../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../controllers/cart_controller.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../models/cart_model.dart';
import '../../restaurants/models/menu_item_model.dart';

class RestaurantCartDetailsPage extends StatefulWidget {
  final RestaurantCartResponse cart;
  const RestaurantCartDetailsPage({super.key, required this.cart});

  @override
  State<RestaurantCartDetailsPage> createState() => _RestaurantCartDetailsPageState();
}

class _RestaurantCartDetailsPageState extends State<RestaurantCartDetailsPage> {
  final CartController controller = Get.find<CartController>();
  bool _isInvoiceExpanded = false;


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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'السلة',
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        actions: [
          CustomIconButtonApp(
            onTap: () {
              AppDialogs.showDeleteConfirmation(
                title: 'مسح السلة',
                description: 'هل أنت متأكد من مسح جميع المنتجات من السلة؟',
                confirmText: 'مسح',
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
    return InkWell(
      onTap: () {
        Get.to(() => RestaurantDetailsScreen(restaurantId: widget.cart.restaurant.restaurantId!!))?.then((value) {
          controller.fetchRestaurantCart(widget.cart.restaurant.id!);
        },);
      },
      child: Container(
        padding: EdgeInsetsDirectional.only(start: 16.76.w, top: 1, bottom: 1 ),
        height: 73.51.h,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
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
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
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
                    style: TextStyle().textColorBold(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.titleMedium?.color,
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
                        style: TextStyle().textColorNormal(
                          fontSize: 12.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color,
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
              // width: 16.w,
              // height: 16.h,
              onTap: () => Navigator.pop(context),
              childWidget: Transform.rotate(
                angle: 3.14159, // 180 degrees
                child: SvgIcon(
                  iconName: 'assets/svg/arrow-right.svg',
                  width: 16.w,
                  height: 16.h,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem cartItem, int index, RestaurantCartResponse currentCart) {
    return Container(
      height: 125.49.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.761,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image (Left in RTL - was Left in Figma)
              Padding(
                padding: EdgeInsetsDirectional.only(top: 22.h, end: 16.w),
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
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
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${cartItem.totalPrice.toStringAsFixed(0)} د.ل',
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
                          width: 100.w,
                          height: 36.h,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Color(0xFFE5E7EB),
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
                                  // width: 28.w,
                                  height: 34.48.h,
                                  alignment: Alignment.center,
                                  child: SvgIcon(
                                    iconName: 'assets/svg/client/restaurant_details/plus_icon.svg',
                                    width: 16.w,
                                    height: 16.h,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                ),
                              ),

                              // Quantity
                              Text(
                                '${cartItem.quantity}',
                                style: TextStyle().textColorBold(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
                                    AppDialogs.showDeleteConfirmation(
                                      title: 'حذف المنتج',
                                      description: 'هل أنت متأكد من حذف هذا المنتج من السلة؟',
                                      onConfirm: () {
                                        controller.removeItem(currentCart.restaurant.id!, index);
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  // width: 28.w,
                                  height: 34.48.h,
                                  alignment: Alignment.center,
                                  child: SvgIcon(
                                    iconName: cartItem.quantity > 1
                                        ? 'assets/svg/client/restaurant_details/minus_icon.svg'
                                        : 'assets/svg/cart/delete.svg',
                                    width: 16.w,
                                    height: 16.h,
                                    color: Theme.of(context).iconTheme.color,
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
              // Delete Button (Right in RTL - was Right in Figma)
              Padding(
                padding: EdgeInsetsDirectional.only(top: 16.h, end: 16.w),
                child: GestureDetector(
                  onTap: () {
                    AppDialogs.showDeleteConfirmation(
                      title: 'حذف المنتج',
                      description: 'هل أنت متأكد من حذف هذا المنتج من السلة؟',
                      onConfirm: () {
                        controller.removeItem(currentCart.restaurant.id!, index);
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
        Get.to(() => RestaurantDetailsScreen(restaurantId: widget.cart.restaurant.restaurantId!!))?.then((value) {
          controller.fetchRestaurantCart(widget.cart.restaurant.id!);
        },);

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
    return Obx(() {
      if (controller.isLoadingDrinks) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.drinks.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Drinks Section
          if (controller.selectedDrinks.isNotEmpty) ...[
            Text(
              'المشروبات المختارة',
              style: TextStyle().textColorBold(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.titleSmall?.color,
              ),
            ),
            SizedBox(height: 12.h),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: controller.selectedDrinks.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final drink = controller.selectedDrinks[index];
                return Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 0.761,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: drink['image'] != null
                                  ? CachedNetworkImage(
                                      imageUrl: drink['image'],
                                      fit: BoxFit.cover,
                                    )
                                  : Container(color: Colors.grey[200]),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  drink['name'],
                                  style: TextStyle().textColorBold(
                                    fontSize: 14.sp,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${(drink['price'] as num).toStringAsFixed(0)} د.ل × ${drink['quantity']}',
                                  style: TextStyle().textColorMedium(
                                    fontSize: 12.sp,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                                if (drink['notes'] != null && drink['notes'].isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4.h),
                                    child: Text(
                                      'ملاحظات: ${drink['notes']}',
                                      style: const TextStyle().textColorNormal(
                                        fontSize: 12.sp,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Delete Button
                           GestureDetector(
                              onTap: () {
                                controller.removeDrink(index);
                              },
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SvgIcon(
                                  iconName: 'assets/svg/cart/delete.svg',
                                  width: 20.w,
                                  height: 20.h,
                                  color: Colors.red.withOpacity(0.7),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 24.h),
          ],
          
          Text(
            'أضف مشروبات',
            style: TextStyle().textColorBold(
              fontSize: 14.sp,
              color: Theme.of(context).textTheme.titleSmall?.color,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 157.49.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.drinks.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                return _buildDrinkCard(controller.drinks[index]);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDrinkCard(MenuItem drink) {
    return Container(
      width: 140.w,
      height: 149.49.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
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
                width: double.infinity,
                height: 80.h,
                padding: EdgeInsets.symmetric(horizontal: 8.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: drink.image != null
                      ? CachedNetworkImage(
                          imageUrl: drink.image!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
                        )
                      : Container(
                          color: Colors.grey[200],
                        ),
                ),
              ),
              SizedBox(height: 12.h),
              // Drink Name
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  drink.name,
                  style: TextStyle().textColorBold(
                    fontSize: 12.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 4.h),
              // Drink Price
              Text(
                '${drink.price.toStringAsFixed(0)} د.ل',
                style: TextStyle().textColorNormal(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          // Add Button
          PositionedDirectional(
            end: 15.24.w,
            top: 64.h,
            child: GestureDetector(
              onTap: () {
                _showAddDrinkBottomSheet(drink);
              },
              child: Container(
                // width: 28.w,
                // height: 28.h,
                padding: EdgeInsets.all(1.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  // border: Border.all(
                  //   color: const Color(0xFFF3F4F6),
                  //   width: 0.761,
                  // ),
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
                    iconName: 'assets/svg/cart/add.svg',
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
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
          GestureDetector(
            onTap: () {
              setState(() {
                _isInvoiceExpanded = !_isInvoiceExpanded;
              });
            },
            child: Container(
              color: Colors.transparent, // Hit test for full width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Chevron Icon (Left in RTL)
                  CustomIconButtonApp(
                    onTap: () {
                      setState(() {
                        _isInvoiceExpanded = !_isInvoiceExpanded;
                      });
                    },
                    childWidget: Transform.rotate(
                      angle: _isInvoiceExpanded ? 3.14159 : 0,
                      child: SvgIcon(
                        iconName: 'assets/svg/cart/arrow-top.svg',
                        width: 20.w,
                        height: 20.h,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                  // Invoice Text (Right in RTL)
                  Text(
                    'الفاتورة',
                    style: TextStyle().textColorBold(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Continue Button
          Obx(() => GestureDetector(
                onTap: controller.isLoading
                    ? null
                    : () {
                        // Pass total price if needed, or rely on backend re-calculation
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
                          'تأكيد الطلب',
                          style: TextStyle().textColorBold(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      // Total Price (Left in RTL)
                      if (!controller.isLoading)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '${(currentCart.totalPrice + _calculateDrinksTotal() + 10).toStringAsFixed(0)} د.ل', // Added dummy delivery fee 10
                            style: TextStyle().textColorBold(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
          
          // Invoice Details (Expandable)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                SizedBox(height: 16.h),
                _buildInvoiceRow('المجموع الفرعي', '${currentCart.totalPrice.toStringAsFixed(0)} د.ل'),
                if (_calculateDrinksTotal() > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: _buildInvoiceRow('المشروبات', '${_calculateDrinksTotal().toStringAsFixed(0)} د.ل'),
                  ),
                SizedBox(height: 12.h),
                _buildInvoiceRow('رسوم التوصيل', '10 د.ل'), // Fixed delivery fee for now
                SizedBox(height: 12.h),
                const Divider(height: 1),
                SizedBox(height: 12.h),
                _buildInvoiceRow(
                  'المجموع الكلي',
                  '${(currentCart.totalPrice + _calculateDrinksTotal() + 10).toStringAsFixed(0)} د.ل',
                  isTotal: true,
                ),
                SizedBox(height: 8.h),
              ],
            ),
            crossFadeState: _isInvoiceExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  double _calculateDrinksTotal() {
    double total = 0;
    for (var drink in controller.selectedDrinks) {
      total += (drink['price'] as num) * (drink['quantity'] as num);
    }
    return total;
  }

  Widget _buildInvoiceRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isTotal
              ? TextStyle().textColorBold(
                  fontSize: 16.sp,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                )
              : TextStyle().textColorNormal(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? TextStyle().textColorBold(
                  fontSize: 16.sp,
                  color: Theme.of(context).primaryColor,
                )
              : TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
        ),
      ],
    );
  }



  void _showAddDrinkBottomSheet(MenuItem drink) {
    int quantity = 1;
    final TextEditingController notesController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2.5.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  drink.name,
                  style: TextStyle().textColorBold(
                    fontSize: 18.sp,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quantity > 1) {
                          setState(() => quantity--);
                        }
                      },
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.remove, color: Theme.of(context).iconTheme.color),
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Text(
                      '$quantity',
                      style: TextStyle().textColorBold(
                        fontSize: 18.sp,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(width: 24.w),
                    GestureDetector(
                      onTap: () {
                        setState(() => quantity++);
                      },
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.add, color: Theme.of(context).iconTheme.color),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: notesController,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  decoration: InputDecoration(
                    hintText: 'ملاحظات (مثل: بدون سكر، ثلج زيادة...)',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 24.h),
                CustomButtonApp(
                  text: 'إضافة للطلب - ${(drink.price * quantity).toStringAsFixed(0)} د.ل',
                  onTap: () {
                    controller.addDrink(drink, quantity, notesController.text);
                    Get.back();
                    showSnackBar(
                      title: 'تمت الإضافة',
                      message: 'تم إضافة ${drink.name} إلى الطلب',
                      isSuccess: true,
                    );
                  },
                  color: const Color(0xFF7F22FE),
                ),
                SizedBox(height: 16.h),
              ],
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }
}
