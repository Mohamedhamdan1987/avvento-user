import 'dart:math';

import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/core/widgets/shimmer/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../cart/models/cart_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/pages/restaurant_cart_details_page.dart';
import '../models/menu_item_model.dart';
import '../controllers/restaurant_details_controller.dart';
import '../models/menu_category_model.dart';
import '../models/restaurant_model.dart';
import 'meal_details_dialog.dart';

class CategoryMenuPage extends StatelessWidget {
  final Restaurant restaurant;
  final MenuCategory category;

  CategoryMenuPage({
    super.key,
    required this.restaurant,
    required this.category,
  });

  RestaurantDetailsController get controller => Get.find<RestaurantDetailsController>();
  CartController get cartController =>
      Get.isRegistered<CartController>() ? Get.find<CartController>() : Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    
    // Set the category and fetch subcategories when entering this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectCategory(category.id);
    });

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          controller.clearFilters();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: category.name,
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Obx(() {
          final cart = cartController.carts.firstWhereOrNull(
            (c) =>
                c.restaurant.restaurantId == restaurant.id ||
                c.restaurant.id == restaurant.id,
          );

          if (cart == null || cart.items.isEmpty) {
            return const SizedBox.shrink();
          }

          return _buildViewCartButton(context, cart);
        }),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              SizedBox(height: 2.h),
            // Subcategories Horizontal List
            Obx(() {
              if (controller.isLoadingSubCategories && controller.subCategories.isEmpty) {
                return const _SubCategoriesShimmer();
              }
              if (controller.subCategories.isEmpty) return const SizedBox.shrink();
              
              return Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                height: 72.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.subCategories.length + 1,
                  separatorBuilder: (context, index) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Obx(() {
                        final isSelected = controller.selectedSubCategoryId.isEmpty;
                        return GestureDetector(
                          onTap: () => controller.selectSubCategory(''),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF7F22FE) : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20.r),
                              border: isSelected ? null : Border.all(color: Theme.of(context).dividerColor),
                            ),
                            child: Text(
                              'الكل',
                              style: const TextStyle().textColorMedium(
                                fontSize: 14.sp,
                                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        );
                      });
                    }
                    
                    final subCategory = controller.subCategories[index - 1];
                    return Obx(() {
                      final isSelected = controller.selectedSubCategoryId == subCategory.id;
                      return GestureDetector(
                        onTap: () => controller.selectSubCategory(subCategory.id),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF7F22FE) : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20.r),
                            border: isSelected ? null : Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Text(
                            subCategory.name,
                            style: const TextStyle().textColorMedium(
                              fontSize: 14.sp,
                              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              );
            }),

            // Items List
            Expanded(
              child: Obx(() {
                if (controller.isLoadingItems && controller.items.isEmpty) {
                  return const _ItemsListShimmer();
                }
                
                // When we are in this page, we only want to see items 
                // that belong to this category (and selected subcategory)
                final items = controller.items.where((item) => item.categoryId == category.id).toList();

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد أصناف في هذا القسم',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 92.h),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItemCard(context, item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildViewCartButton(BuildContext context, RestaurantCartResponse cart) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: GestureDetector(
          onTap: () {
            Get.to(() => RestaurantCartDetailsPage(cart: cart));
          },
          child: Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: const Color(0xFF101828),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.761,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF99A1AF).withOpacity(0.3),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 10.w, end: 24.w),
              child: Row(
                children: [
                  Container(
                    width: 37.r,
                    height: 37.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${cart.items.length}',
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: const Color(0xFF101828),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سلة المشتريات',
                        style: TextStyle().textColorBold(
                          fontSize: 10.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${cart.totalPrice.toStringAsFixed(2)} د.ل',
                        style: TextStyle().textColorMedium(
                          fontSize: 10.sp,
                          color: const Color(0xFF99A1AF),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => RestaurantCartDetailsPage(cart: cart));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'إتمام الطلب',
                            style: TextStyle().textColorBold(
                              fontSize: 10.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Transform.rotate(
                            angle: pi,
                            child: SvgIcon(
                              iconName: 'assets/svg/arrow-right.svg',
                              width: 16.w,
                              height: 16.h,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, MenuItem item) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MealDetailsDialog(menuItem: item),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        child: Row(
          children: [
            // Item Image
            Container(
              width: 88.w,
              height: 76.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: item.image != null && item.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.image!,
                        width: 88.w,
                        height: 76.h,
                        fit: BoxFit.cover,
                      )
                    : Container(color: Colors.grey[300]),
              ),
            ),

            SizedBox(width: 12.w),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const Spacer(),
                      Obx(() {
                        final quantity = cartController.getItemQuantityInCart(
                          restaurant.id,
                          item.id,
                        );
                        final isUpdating = cartController.isItemUpdating(item.id);

                        if (quantity > 0) {
                          return Container(
                            height: 28.h,
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF101828),
                              borderRadius: BorderRadius.circular(100.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: isUpdating
                                      ? null
                                      : () => _updateQuantity(
                                            context,
                                            item,
                                            quantity - 1,
                                          ),
                                  child: AnimatedOpacity(
                                    opacity: isUpdating ? 0.4 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      quantity == 1 ? Icons.delete_outline : Icons.remove,
                                      color: quantity == 1 ? const Color(0xFFFF4D4D) : Colors.white,
                                      size: 16.w,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                SizedBox(
                                  width: 18.w,
                                  height: 18.h,
                                  child: Center(
                                    child: isUpdating
                                        ? SizedBox(
                                            width: 14.w,
                                            height: 14.h,
                                            child: const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            '$quantity',
                                            style: const TextStyle().textColorBold(
                                              fontSize: 14.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: isUpdating
                                      ? null
                                      : () => _updateQuantity(
                                            context,
                                            item,
                                            quantity + 1,
                                          ),
                                  child: AnimatedOpacity(
                                    opacity: isUpdating ? 0.4 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16.w,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (isUpdating) {
                          return Container(
                            width: 32.w,
                            height: 32.h,
                            decoration: const BoxDecoration(
                              color: Color(0xFF101828),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }

                        return CustomIconButtonApp(
                          width: 32.w,
                          height: 32.h,
                          radius: 100.r,
                          color: const Color(0xFF101828),
                          onTap: () async {
                            if (item.variations.isEmpty && item.addOns.isEmpty) {
                              cartController.setItemUpdating(item.id);
                              try {
                                await controller.addToCart(
                                  itemId: item.id,
                                  quantity: 1,
                                  selectedVariations: [],
                                  selectedAddOns: [],
                                );
                              } finally {
                                cartController.clearItemUpdating(item.id);
                              }
                            } else {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => MealDetailsDialog(menuItem: item),
                              );
                            }
                          },
                          childWidget: SvgIcon(
                            iconName: 'assets/svg/plus-solid.svg',
                            width: 16.w,
                            height: 16.h,
                            color: Colors.white,
                          ),
                        );
                      }),
                      SizedBox(width: 8.w),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle().textColorMedium(
                      fontSize: 12.sp,
                      color: (Theme.of(context).textTheme.titleLarge?.color ?? Colors.black).withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${item.price} د.ل',
                    style: const TextStyle().textColorMedium(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _updateQuantity(
    BuildContext context,
    MenuItem item,
    int newQuantity,
  ) async {
    if (cartController.isItemUpdating(item.id)) return;

    cartController.setItemUpdating(item.id);
    try {
      final itemIndex = cartController.getItemIndexInCart(
        restaurant.id,
        item.id,
      );
      final cartRestaurantId = restaurant.user.id;
      // cprint("cartRestaurantId: ${cartController.detailedCart?.restaurant.id}");
      // cprint("cartRestaurantId: ${restaurant.user.id}");
      // cprint("cartRestaurantId: ${restaurant.id}");

      if (newQuantity == 0) {
        if (itemIndex != -1) {
          await cartController.removeItem(cartRestaurantId, itemIndex);
        }
      } else {
        if (itemIndex != -1) {
          await cartController.updateCartItemQuantity(
            cartRestaurantId,
            itemIndex,
            newQuantity,
          );
        } else {
          await controller.addToCart(
            itemId: item.id,
            quantity: newQuantity,
            selectedVariations: [],
            selectedAddOns: [],
          );
        }
      }
    } finally {
      cartController.clearItemUpdating(item.id);
    }
  }
}

class _SubCategoriesShimmer extends StatelessWidget {
  const _SubCategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        height: 72.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, __) => ShimmerBox(
            width: 80.w,
            height: 40.h,
            borderRadius: 20,
          ),
        ),
      ),
    );
  }
}

class _ItemsListShimmer extends StatelessWidget {
  const _ItemsListShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: 6,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            children: [
              ShimmerBox(width: 88.w, height: 76.h, borderRadius: 10),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 140.w, height: 14.h, borderRadius: 8),
                    SizedBox(height: 8.h),
                    ShimmerBox(width: double.infinity, height: 12.h, borderRadius: 6),
                    SizedBox(height: 8.h),
                    ShimmerBox(width: 60.w, height: 12.h, borderRadius: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
