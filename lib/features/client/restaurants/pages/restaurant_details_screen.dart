
//
// import 'package:avvento/core/theme/app_text_styles.dart';
// import 'package:avvento/core/widgets/reusable/svg_icon.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
// import 'meal_details_dialog.dart';
//
// class RestaurantDetailsScreen extends StatelessWidget {
//   final String restaurantId;
//   const RestaurantDetailsScreen({super.key, required this.restaurantId});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Column(
//           children: [
//             // Top Header Section with Background Image
//             _buildHeaderSection(context),
//             SizedBox(height: 60.h),
//
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Restaurant Stats Row
//                     _buildStatsRow(),
//
//                     SizedBox(height: 14.h),
//
//                     // Today's Offers Section
//                     _buildTodaysOffersSection(),
//
//                     SizedBox(height: 32.h),
//
//                     // Browse Menu Section
//                     _buildBrowseMenuSection(),
//
//                     SizedBox(height: 32.h),
//
//                     // All Items Section
//                     _buildAllItemsSection(context),
//
//                     SizedBox(height: 32.h),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderSection(BuildContext context) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         // Background Image
//         Container(
//           height: 280.h,
//           width: double.infinity,
//           child: ClipRRect(
//             borderRadius: BorderRadius.only(bottomRight: Radius.circular(40.r)),
//             child: CachedNetworkImage(
//               imageUrl:
//               "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800",
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: 280.h,
//             ),
//           ),
//         ),
//
//         // Gradient Overlay
//         Container(
//           height: 280.h,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.only(bottomRight: Radius.circular(40.r)),
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Colors.transparent,
//                 Colors.black.withOpacity(0.1),
//                 Color(0xFF101828).withOpacity(0.8),
//               ],
//               stops: [0.0, 0.5, 1.0],
//             ),
//           ),
//         ),
//
//         // Navigation Buttons (Top Right in RTL = Top Left visually)
//         Positioned(
//           width: MediaQuery.of(context).size.width,
//           top: 48.h,
//           // right: 24.w,
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 24.w),
//             child: Row(
//               children: [
//                 CustomIconButtonApp(
//                   width: 40.w,
//                   height: 40.h,
//                   radius: 100.r,
//                   color: Color(0xB37F22FE),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   childWidget: SvgIcon(
//                     iconName: 'assets/svg/arrow-right.svg',
//                     width: 20.w,
//                     height: 20.h,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Spacer(),
//                 CustomIconButtonApp(
//                   width: 40.w,
//                   height: 40.h,
//                   radius: 100.r,
//                   color: Color(0x997F22FE),
//                   onTap: () {},
//                   childWidget: SvgIcon(
//                     iconName: 'assets/svg/search-icon.svg',
//                     width: 20.w,
//                     height: 20.h,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 CustomIconButtonApp(
//                   width: 40.w,
//                   height: 40.h,
//                   radius: 100.r,
//                   color: Color(0x997F22FE),
//                   onTap: () {},
//                   childWidget: SvgIcon(
//                     iconName: 'assets/svg/share_icon.svg',
//                     width: 20.w,
//                     height: 20.h,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//         // Restaurant Name and Description (Bottom Right in RTL)
//         Positioned(
//           bottom: 16.h,
//           right: 24.w,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 'مطعم الكوخ',
//                 style: TextStyle().textColorBold(
//                   fontSize: 25.sp,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 4.h),
//               Text(
//                 'أفضل المأكولات الشامية',
//                 style: TextStyle().textColorMedium(
//                   fontSize: 14.sp,
//                   color: Colors.white.withOpacity(0.7),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Profile Picture Overlapping
//         _buildProfilePicture(),
//       ],
//     );
//   }
//
//   Widget _buildProfilePicture() {
//     return PositionedDirectional(
//       bottom: -50.h,
//       end: 43.w,
//       child: Container(
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white, width: 3.w),
//         ),
//         child: Container(
//           width: 98.w,
//           height: 98.h,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: Color(0xFF7F22FE), width: 3.w),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.15),
//                 blurRadius: 8,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: ClipOval(
//             child: CachedNetworkImage(
//               imageUrl:
//               "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=200",
//               width: 98.w,
//               height: 98.h,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatsRow() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 34.w),
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//       decoration: BoxDecoration(
//         color: Color(0x12D9D9D9),
//         borderRadius: BorderRadius.circular(21.r),
//         border: Border.all(color: Color(0x33E3E3E3), width: 1),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildStatItem(
//             icon: 'assets/svg/client/restaurant_details/clock.svg',
//             value: '25 دقيقة',
//             label: 'التحضير',
//           ),
//           Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
//           _buildStatItem(
//             icon: 'assets/svg/client/restaurant_details/location.svg',
//             value: '1.2 كم',
//             label: 'المسافة',
//           ),
//           Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
//           _buildStatItem(
//             icon: 'assets/svg/client/restaurant_details/bike.svg',
//             value: '10',
//             label: 'التوصيل',
//           ),
//           Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
//           _buildStatItem(
//             icon: 'assets/svg/client/restaurant_details/inactive_star_icon.svg',
//             value: '4.8',
//             label: 'التقييم',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatItem({
//     required String icon,
//     required String value,
//     required String label,
//   }) {
//     return Column(
//       children: [
//         SvgIcon(
//           iconName: icon,
//           width: 16.w,
//           height: 16.h,
//           color: Color(0xFF101828),
//         ),
//         SizedBox(height: 4.h),
//         Text(
//           value,
//           style: TextStyle().textColorBold(
//             fontSize: 8.sp,
//             color: Color(0xFF101828),
//           ),
//         ),
//         SizedBox(height: 2.h),
//         Text(
//           label,
//           style: TextStyle().textColorBold(
//             fontSize: 8.sp,
//             color: Color(0xFF99A1AF),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTodaysOffersSection() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title
//           Row(
//             spacing: 8.w,
//             children: [
//               SvgIcon(
//                 iconName: 'assets/svg/client/restaurant_details/flame_icon.svg',
//                 width: 20.w,
//                 height: 20.h,
//                 color: Color(0xFF7F22FE),
//               ),
//               Text(
//                 'عروضنا لهذا اليوم',
//                 style: TextStyle().textColorBold(
//                   fontSize: 18.sp,
//                   color: Color(0xFF101828),
//                 ),
//               ),
//             ],
//           ),
//
//           SizedBox(height: 16.h),
//
//           // Offer Card
//           Container(
//             padding: EdgeInsets.only(
//               left: 12.w,
//               right: 12.w,
//               top: 12.h,
//               bottom: 24.h,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24.r),
//               border: Border.all(color: Color(0xFFF3F4F6), width: 0.76.w),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 20,
//                   offset: Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 // Offer Image
//                 Stack(
//                   clipBehavior: Clip.none,
//                   alignment: Alignment.bottomCenter,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(20.r),
//                       child: Container(
//                         width: 96.w,
//                         height: 96.h,
//                         decoration: BoxDecoration(
//                           color: Color(0xFFF9FAFB),
//                           borderRadius: BorderRadius.circular(20.r),
//                         ),
//                         child: CachedNetworkImage(
//                           imageUrl:
//                           "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200",
//                           width: 96.w,
//                           height: 96.h,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     // Add Button Overlay
//                     Positioned(
//                       bottom: -13.h,
//                       child: CustomIconButtonApp(
//                         width: 32.w,
//                         height: 32.h,
//                         radius: 100.r,
//                         color: Color(0xFF101828),
//                         onTap: () {},
//                         childWidget: SvgIcon(
//                           iconName: 'assets/svg/plus-solid.svg',
//                           width: 16.w,
//                           height: 16.h,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 SizedBox(width: 12.w),
//
//                 // Offer Details
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'عرض وجبة عائلية',
//                         style: TextStyle().textColorBold(
//                           fontSize: 16.sp,
//                           color: Color(0xFF101828),
//                         ),
//                       ),
//                       SizedBox(height: 4.h),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               'شريحة لحم بقري، جبنة شيدر، خس، طماطم، صوص خاص',
//                               style: TextStyle().textColorNormal(
//                                 fontSize: 12.sp,
//                                 color: Color(0xFF99A1AF),
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Text(
//                                 '150',
//                                 style: TextStyle().textColorBold(
//                                   fontSize: 18.sp,
//                                   color: Color(0xFF7F22FE),
//                                 ),
//                               ),
//                               SizedBox(width: 4.w),
//                               Text(
//                                 'د.ل',
//                                 style: TextStyle().textColorNormal(
//                                   fontSize: 12.sp,
//                                   color: Color(0xFF99A1AF),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBrowseMenuSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsetsDirectional.only(start: 24.w),
//           child: Text(
//             'تصفح المنيو',
//             style: TextStyle().textColorBold(
//               fontSize: 18.sp,
//               color: Color(0xFF101828),
//             ),
//           ),
//         ),
//
//         SizedBox(height: 16.h),
//
//         SizedBox(
//           height: 140.h,
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             children: [
//               SizedBox(width: 24.w),
//               _buildMenuCategoryCard(
//                 imageUrl:
//                 "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200",
//                 title: 'برجر',
//                 count: '12 وجبة',
//               ),
//               SizedBox(width: 16.w),
//               _buildMenuCategoryCard(
//                 imageUrl:
//                 "https://images.unsplash.com/photo-1534939561126-855b8675edd7?w=200",
//                 title: 'ساندوتش',
//                 count: '8 أنواع',
//               ),
//               SizedBox(width: 16.w),
//               _buildMenuCategoryCard(
//                 imageUrl:
//                 "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200",
//                 title: 'وجبات',
//                 count: '5 عروض',
//               ),
//               SizedBox(width: 16.w),
//               _buildMenuCategoryCard(
//                 imageUrl:
//                 "https://images.unsplash.com/photo-1551024506-0bccd828d307?w=200",
//                 title: 'مشروبات',
//                 count: '14 نوع',
//               ),
//               SizedBox(width: 24.w),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMenuCategoryCard({
//     required String imageUrl,
//     required String title,
//     required String count,
//   }) {
//     return Container(
//       width: 120.w,
//       height: 140.h,
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(24.r),
//             child: CachedNetworkImage(
//               imageUrl: imageUrl,
//               width: 120.w,
//               height: 140.h,
//               fit: BoxFit.cover,
//             ),
//           ),
//           // Dark Overlay
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(24.r),
//               color: Colors.black.withOpacity(0.4),
//             ),
//           ),
//           // Content
//           Positioned(
//             bottom: 12.h,
//             right: 12.w,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle().textColorBold(
//                     fontSize: 14.sp,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 2.h),
//                 Text(
//                   count,
//                   style: TextStyle().textColorNormal(
//                     fontSize: 10.sp,
//                     color: Colors.white.withOpacity(0.8),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAllItemsSection(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Section Title
//           Row(
//             spacing: 8.w,
//             children: [
//               SvgIcon(
//                 iconName: 'assets/svg/client/restaurant_details/menu_icon.svg',
//                 width: 20.w,
//                 height: 20.h,
//               ),
//               Text(
//                 'جميع الأصناف',
//                 style: TextStyle().textColorBold(
//                   fontSize: 18.sp,
//                   color: Color(0xFF101828),
//                 ),
//               ),
//             ],
//           ),
//
//           SizedBox(height: 16.h),
//
//           // Items List
//           ...List.generate(3, (index) => _buildItemCard(context)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItemCard(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // showModalBottomSheet(
//         //   context: context,
//         //   isScrollControlled: true,
//         //   backgroundColor: Colors.transparent,
//         //   builder: (context) => MealDetailsDialog(),
//         // );
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 16.h),
//         child: Row(
//           children: [
//             // Item Image
//             Container(
//               width: 88.w,
//               height: 76.h,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.25),
//                     blurRadius: 4,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10.r),
//                 child: CachedNetworkImage(
//                   imageUrl:
//                   "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200",
//                   width: 88.w,
//                   height: 76.h,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//
//             SizedBox(width: 12.w),
//
//             // Item Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'وجبة فواكه البحر',
//                     style: TextStyle().textColorBold(
//                       fontSize: 14.sp,
//                       color: Color(0xFF0A191E),
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     'وجبات صحية',
//                     style: TextStyle().textColorMedium(
//                       fontSize: 12.sp,
//                       color: Color(0xFF0A191E),
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     '15 د.ل',
//                     style: TextStyle().textColorMedium(
//                       fontSize: 12.sp,
//                       color: Color(0xFF0A191E),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Quantity Selector
//             _buildQuantitySelector(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuantitySelector() {
//     return Container(
//       width: 70.w,
//       height: 28.h,
//       decoration: BoxDecoration(
//         color: Color(0xFF121223),
//         borderRadius: BorderRadius.circular(50.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 20,
//             offset: Offset(0, 12),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(100.r),
//             onTap: () {},
//             child: SvgIcon(
//               iconName: 'assets/svg/client/restaurant_details/minus_icon.svg',
//               width: 14,
//               height: 14,
//               color: Colors.white,
//             ),
//           ),
//           Text(
//             '0',
//             style: TextStyle().textColorBold(
//               fontSize: 10.sp,
//               color: Colors.white,
//             ),
//           ),
//           InkWell(
//             borderRadius: BorderRadius.circular(100.r),
//             onTap: () {},
//             child: SvgIcon(
//               iconName: 'assets/svg/client/restaurant_details/plus_icon.svg',
//               width: 14,
//               height: 14,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:math';
import 'dart:ui';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/utils/show_snackbar.dart';
import 'package:avvento/features/client/restaurants/models/menu_item_model.dart';
import 'package:avvento/features/client/restaurants/models/restaurant_model.dart';
import 'package:avvento/features/client/restaurants/pages/category_menu_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../../../../core/widgets/reusable/svg_icon.dart';
import '../controllers/restaurant_details_controller.dart';
import '../../../../core/utils/location_utils.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/models/cart_model.dart';
import '../../cart/pages/restaurant_cart_details_page.dart';
import '../controllers/restaurants_controller.dart';
import 'meal_details_dialog.dart';
import 'restaurant_search_page.dart';
import '../../../../core/widgets/shimmer/shimmer_loading.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final String restaurantId;
  final bool fromCart;

  RestaurantDetailsScreen({super.key, required this.restaurantId, this.fromCart = false}) {
    if (!Get.isRegistered<RestaurantsController>()) {
      Get.put(RestaurantsController());
    }
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController());
    } else {
      // Use microtask to avoid "setState() or markNeedsBuild() called during build" error
      Future.microtask(() => Get.find<CartController>().fetchAllCarts());
    }
    if (Get.isRegistered<RestaurantDetailsController>()) {
      Get.delete<RestaurantDetailsController>(force: true);
    }
    Get.put(RestaurantDetailsController(restaurantId: restaurantId));
  }

  RestaurantDetailsController get controller {
    if (Get.isRegistered<RestaurantDetailsController>()) {
      return Get.find<RestaurantDetailsController>();
    }
    // Re-register if controller was cleaned up during navigation transition
    return Get.put(RestaurantDetailsController(restaurantId: restaurantId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        if (!Get.isRegistered<CartController>()) return const SizedBox.shrink();
        final cartController = Get.find<CartController>();
        final cart = cartController.carts.firstWhereOrNull(
          (c) => c.restaurant.restaurantId == restaurantId,
        );

        if (cart == null || cart.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildViewCartButton(context, cart);
      }),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (!Get.isRegistered<RestaurantDetailsController>()) {
            return const SizedBox.shrink();
          }
          if (controller.isLoadingRestaurantDetails && controller.restaurant == null) {
            return const RestaurantDetailsShimmer();
          }

          if (controller.hasError && controller.restaurant == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.w, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      controller.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: controller.getRestaurantDetails,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.restaurant == null) {
            return const Center(child: Text('المطعم غير موجود'));
          }


          return CustomScrollView(
            slivers: [
              // Shrinking Header
              SliverPersistentHeader(
                pinned: true,
                delegate: RestaurantHeaderDelegate(
                  restaurant: controller.restaurant!,
                  onBack: () => Navigator.pop(context),
                  onSearch: () {
                    Get.to(() => RestaurantSearchPage(
                          restaurant: controller.restaurant!,
                          categories: controller.categories,
                          allItems: controller.allItems,
                        ));
                  },
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50.h),

                    // Restaurant Stats Row
                    _buildOpenStats(context),

                    SizedBox(height: 14.h),
                    _buildStatsRow(context),

                    SizedBox(height: 14.h),

                    // Browse Menu Section
                    _buildBrowseMenuSection(context),

                    SizedBox(height: 32.h),

                    // All Items Section
                    _buildAllItemsSection(context),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Header section refactored into RestaurantHeaderDelegate

  // Profile picture refactored into RestaurantHeaderDelegate

  Widget _buildOpenStats(BuildContext context) {
    return InkWell(
      onTap: () => _showOpeningHoursSheet(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final isOpen = controller.restaurant?.isOpen?? false;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: isOpen ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isOpen ? Colors.green : Colors.red).withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isOpen ? 'مفتوح الآن' : 'مغلق حالياً',
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 4.h),
                Obx(() {
                  final status = controller.schedule?.currentDayStatus;
                  if (status == null) return const SizedBox.shrink();

                  final nextTime = status.isCurrentlyOpen ? status.closeTime : status.openTime;
                  final text = status.isCurrentlyOpen ? 'يغلق الساعة $nextTime' : 'يفتح الساعة $nextTime';

                  return Text(
                    text,
                    style: TextStyle().textColorMedium(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  );
                }),
              ],
            ),
            Row(
              children: [
                Text(
                  'مواعيد العمل',
                  style: TextStyle().textColorMedium(
                    fontSize: 12.sp,
                    color: AppColors.purple,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20.w,
                  color: AppColors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOpeningHoursSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsetsDirectional.only(top: 16.w, start: 16.w, bottom: 24.w, end: 8.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              // Container(
              //   width: 40.w,
              //   height: 4.h,
              //   decoration: BoxDecoration(
              //     color: Theme.of(context).dividerColor,
              //     borderRadius: BorderRadius.circular(2.r),
              //   ),
              // ),
              // SizedBox(height: 24.h),

              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: SvgIcon(
                      iconName: 'assets/svg/client/restaurant_details/clock.svg',
                      width: 24.w,
                      height: 24.h,
                      color: AppColors.purple,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مواعيد العمل',
                          style: TextStyle().textColorBold(
                            fontSize: 18.sp,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        Text(
                          controller.restaurant?.name ?? '',
                          style: TextStyle().textColorMedium(
                            fontSize: 14.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Days List
              Obx(() {
                if (controller.isLoadingSchedule) {
                  return ShimmerLoading(
                    child: Column(
                      children: List.generate(7, (_) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShimmerBox(width: 60.w, height: 14.h, borderRadius: 6),
                              ShimmerBox(width: 100.w, height: 14.h, borderRadius: 6),
                            ],
                          ),
                        ),
                      )),
                    ),
                  );
                }

                final schedule = controller.schedule;
                if (schedule == null) {
                  return const Center(child: Text('لا توجد بيانات مواعيد'));
                }

                final daysArabic = {
                  'sunday': 'الأحد',
                  'monday': 'الاثنين',
                  'tuesday': 'الثلاثاء',
                  'wednesday': 'الأربعاء',
                  'thursday': 'الخميس',
                  'friday': 'الجمعة',
                  'saturday': 'السبت',
                };

                return Column(
                  children: schedule.weeklySchedule.map((s) {
                    final isCurrent = s.day.toLowerCase() == schedule.currentDayStatus.day.toLowerCase();
                    final hoursText = s.isClosed ? 'مغلق' : '${s.openTime} - ${s.closeTime}';
                    return _buildDayRow(context, daysArabic[s.day.toLowerCase()] ?? s.day, hoursText, isCurrent: isCurrent);
                  }).toList(),
                );
              }),

              SizedBox(height: 32.h),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'إغلاق',
                    style: TextStyle().textColorBold(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, String day, String hours, {bool isCurrent = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.purple.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: isCurrent ? Border.all(color: AppColors.purple.withOpacity(0.2)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle().textColorMedium(
              fontSize: 14.sp,
              color: isCurrent ? AppColors.purple : Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          Text(
            hours,
            style: TextStyle().textColorBold(
              fontSize: 14.sp,
              color: isCurrent ? AppColors.purple : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    String distanceText = '--';
    String priceText = '--';
    final restaurantsController = Get.find<RestaurantsController>();
    if (restaurantsController.userLat != null && restaurantsController.userLong != null) {
      final distance = LocationUtils.calculateDistance(
        userLat: restaurantsController.userLat!,
        userLong: restaurantsController.userLong!,
        restaurantLat: controller.restaurant!.lat,
        restaurantLong: controller.restaurant!.long,
      );
      distanceText = LocationUtils.formatDistance(distance);
      final price = LocationUtils.calculateDeliveryPrice(distanceInKm: distance, );
      priceText = LocationUtils.formatPrice(price);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
      decoration: ShapeDecoration(
        color: const Color(0x11D9D9D9),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0x33E3E3E3),
          ),
          borderRadius: BorderRadius.circular(21),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/clock.svg',
            value: '${controller.restaurant!.averagePreparationTimeMinutes} دقيقة',
            label: 'التحضير',
          ),
          Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/location.svg',
            value: distanceText,
            label: 'المسافة',
          ),
          Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/bike.svg',
            value: priceText,
            label: 'التوصيل',
          ),
          Container(width: 1.w, height: 32.h, color: Color(0xFFF3F4F6)),
          _buildStatItem(
            context,
            icon: 'assets/svg/client/restaurant_details/inactive_star_icon.svg',
            value: controller.restaurant!.averageRatingDisplay,
            label: 'التقييم',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        SvgIcon(
          iconName: icon,
          width: 16.w,
          height: 16.h,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle().textColorBold(
            fontSize: 8.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle().textColorBold(
            fontSize: 8.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysOffersSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            spacing: 8.w,
            children: [
              SvgIcon(
                iconName: 'assets/svg/client/restaurant_details/flame_icon.svg',
                width: 20.w,
                height: 20.h,
                color: Color(0xFF7F22FE),
              ),
              Text(
                'عروضنا لهذا اليوم',
                style: TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Offer Card
          Container(
            padding: EdgeInsets.only(
              left: 12.w,
              right: 12.w,
              top: 12.h,
              bottom: 24.h,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Theme.of(context).dividerColor, width: 0.76.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Offer Image
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        width: 96.w,
                        height: 96.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200",
                          width: 96.w,
                          height: 96.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Add Button Overlay
                    Positioned(
                      bottom: -13.h,
                      child: CustomIconButtonApp(
                        width: 32.w,
                        height: 32.h,
                        radius: 100.r,
                        color: Color(0xFF101828), // This button color might need check, maybe dark compliant or kept as brand
                        onTap: () {},
                        childWidget: SvgIcon(
                          iconName: 'assets/svg/plus-solid.svg',
                          width: 16.w,
                          height: 16.h,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 12.w),

                // Offer Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عرض وجبة عائلية',
                        style: TextStyle().textColorBold(
                          fontSize: 16.sp,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'شريحة لحم بقري، جبنة شيدر، خس، طماطم، صوص خاص',
                              style: TextStyle().textColorNormal(
                                fontSize: 12.sp,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '150',
                                style: TextStyle().textColorBold(
                                  fontSize: 18.sp,
                                  color: Color(0xFF7F22FE),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'د.ل',
                                style: TextStyle().textColorNormal(
                                  fontSize: 12.sp,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseMenuSection(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 24.w),
          child: Text(
            'تصفح المنيو',
            style: const TextStyle().textColorBold(
              fontSize: 18.sp,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),

        SizedBox(height: 16.h),

        SizedBox(
          height: 140.h,
          child: Obx(() {
            if (controller.isLoadingCategories && controller.categories.isEmpty) {
              return const MenuCategoriesShimmer();
            }
            if (controller.categories.isEmpty) {
              return const Center(child: Text('لا توجد تصنيفات'));
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              scrollDirection: Axis.horizontal,
              itemCount: controller.categories.length,
              separatorBuilder: (context, index) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return GestureDetector(
                   behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Get.to(() => CategoryMenuPage(
                          restaurant: controller.restaurant!,
                          category: category,
                        ));
                  },
                  child: _buildMenuCategoryCard(
                    imageUrl: category.image ?? "",
                    title: category.name,
                    count: "",
                    isSelected: false, // No selection state on the main screen anymore
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMenuCategoryCard({
    required String imageUrl,
    required String title,
    required String count,
    bool isSelected = false,
  }) {
    return Container(
      width: 120.w,
      height: 140.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: isSelected ? Border.all(color: Color(0xFF7F22FE), width: 2.w) : null,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 120.w,
                    height: 140.h,
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.grey[300]),
          ),
          // Dark Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          // Content
          Positioned(
            bottom: 12.h,
            right: 12.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle().textColorBold(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
                if (count.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    count,
                    style: const TextStyle().textColorNormal(
                      fontSize: 10.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllItemsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            spacing: 8.w,
            children: [
              SvgIcon(
                iconName: 'assets/svg/client/restaurant_details/menu_icon.svg',
                width: 20.w,
                height: 20.h,
              ),
              Text(
                'جميع الأصناف',
                style: const TextStyle().textColorBold(
                  fontSize: 18.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Items List
          Obx(() {
            if (controller.isLoadingItems && controller.items.isEmpty) {
              return const MenuItemsShimmer();
            }
            if (controller.items.isEmpty) {
              return const Center(child: Text('لا توجد أصناف'));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < controller.items.length; i++) ...[
                  if (i == 0 ||
                      controller.items[i].categoryId !=
                          controller.items[i - 1].categoryId)
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: 16.h, bottom: 8.h),
                      child: Text(
                        controller.items[i].categoryName,
                        style: const TextStyle().textColorBold(
                          fontSize: 16.sp,
                          color: Colors.grey, // Changed to grey as requested
                        ),
                      ),
                    ),
                  _buildItemCard(context, controller.items[i]),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, MenuItem item) {
    final cartController = Get.find<CartController>();
    final quantity = cartController.getItemQuantityInCart(restaurantId, item.id);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.76.w),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Item Image with Add Button
            GestureDetector(
              onTap: () {
                _showMealDetails(context, item);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  width: 96.w,
                  height: 96.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: (item.image?.isNotEmpty ?? false)
                      ? CachedNetworkImage(
                    imageUrl: item.image!,
                    width: 96.w,
                    height: 96.h,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.fastfood, size: 40.w, color: Colors.grey),
                ),
              ),
            ),


            SizedBox(width: 12.w),

            // Item Details
            Expanded(
              child: GestureDetector(
                onTap: () => _showMealDetails(context, item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle().textColorBold(
                              fontSize: 16.sp,
                              color: Theme.of(context).textTheme.titleMedium?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        quantity > 0
                            ? Container(
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
                                onTap: cartController.isItemUpdating(item.id)
                                    ? null
                                    : () => _updateQuantity(context, item, quantity - 1),
                                child: AnimatedOpacity(
                                  opacity: cartController.isItemUpdating(item.id) ? 0.4 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(Icons.remove, color: Colors.white, size: 16.w),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              SizedBox(
                                width: 18.w,
                                height: 18.h,
                                child: Center(
                                  child: cartController.isItemUpdating(item.id)
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
                                          style: TextStyle().textColorBold(fontSize: 14.sp, color: Colors.white),
                                        ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: cartController.isItemUpdating(item.id)
                                    ? null
                                    : () => _updateQuantity(context, item, quantity + 1),
                                child: AnimatedOpacity(
                                  opacity: cartController.isItemUpdating(item.id) ? 0.4 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(Icons.add, color: Colors.white, size: 16.w),
                                ),
                              ),
                            ],
                          ),
                        )
                            : CustomIconButtonApp(
                          width: 32.w,
                          height: 32.h,
                          radius: 100.r,
                          color: const Color(0xFF101828),
                          onTap: () {
                            if (item.variations.isEmpty && item.addOns.isEmpty) {
                              controller.addToCart(
                                itemId: item.id,
                                quantity: 1,
                                selectedVariations: [],
                                selectedAddOns: [],
                              );
                            } else {
                              _showMealDetails(context, item);
                            }
                          },
                          childWidget: SvgIcon(
                            iconName: 'assets/svg/plus-solid.svg',
                            width: 16.w,
                            height: 16.h,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.description,
                      style: TextStyle().textColorNormal(
                        fontSize: 12.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          item.price.toString(),
                          style: TextStyle().textColorBold(
                            fontSize: 18.sp,
                            color: AppColors.purple,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'د.ل',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(MenuItem item) {
    return Obx(() {
      final isFav = controller.isItemFavorite(item.id);
      return GestureDetector(
        onTap: () => controller.toggleFavorite(item.id),
        child: SvgIcon(
          iconName: isFav
              ? 'assets/svg/client/restaurant_details/active_fav_icon.svg'
              : 'assets/svg/client/restaurant_details/fav_icon.svg',
          width: 20.w,
          height: 20.h,
          color: isFav ? Colors.red : null,
        ),
      );
    });
  }

  void _showMealDetails(BuildContext context, MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MealDetailsDialog(
        menuItem: item,
      ),
    );
  }

  Widget _buildViewCartButton(BuildContext context, RestaurantCartResponse cart) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: GestureDetector(
          onTap: () {
            if (fromCart) {
              Get.back();
            } else {
              Get.to(() => RestaurantCartDetailsPage(cart: cart));
            }
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
                  // White circle indicator
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
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
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
                  // Cart info text
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
                  // "إتمام الطلب" pill button
                  GestureDetector(
                    onTap: () {
                      if (fromCart) {
                        Get.back();
                      } else {
                        Get.to(() => RestaurantCartDetailsPage(cart: cart));
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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

  Future<void> _updateQuantity(BuildContext context, MenuItem item, int newQuantity) async {
    final cartController = Get.find<CartController>();
    if (cartController.isItemUpdating(item.id)) return;

    cartController.setItemUpdating(item.id);
    try {
      final itemIndex = cartController.getItemIndexInCart(restaurantId, item.id);

      if (newQuantity == 0) {
        if (itemIndex != -1) {
          await cartController.removeItem(restaurantId, itemIndex);
        }
      } else {
        if (itemIndex != -1) {
          await cartController.updateCartItemQuantity(cartController.detailedCart!.restaurant.id, itemIndex, newQuantity);
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

class RestaurantHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Restaurant restaurant;
  final VoidCallback onBack;
  final VoidCallback onSearch;

  RestaurantHeaderDelegate({
    required this.restaurant,
    required this.onBack,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double progress = shrinkOffset / maxExtent;
    // Calculate values based on progress
    final double avatarSize = 100.w * (1 - progress).clamp(0.6, 1.0);
    final double avatarTop = 150.h - (shrinkOffset * 0.7);
    final double titleOpacity = (progress * 2).clamp(0, 1);

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        // Background Image with Blur
        ClipRRect(
          borderRadius: BorderRadiusDirectional.only(
            bottomStart: Radius.circular(30.r),
          ),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: restaurant.backgroundImage ?? '',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(color: Colors.grey[300]),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: progress * 10,
                  sigmaY: progress * 10,
                ),
                child: Container(
                  color: Colors.black.withOpacity(progress * 0.4),
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        Positioned(
          top: MediaQuery.of(context).padding.top + 10.h,
          left: 20.w,
          right: 20.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconButtonApp(
                onTap: onBack,
                color: Colors.white.withOpacity(0.2),
                childWidget: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
              // Fade in title when scrolled
              Opacity(
                opacity: titleOpacity,
                child: Text(
                  restaurant.name,
                  style: TextStyle().textColorBold(fontSize: 18.sp, color: Colors.white),
                ),
              ),

              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: progress < 0.5 ? 1 : 0,
                child: IgnorePointer(
                    ignoring: progress >= 0.5,
                  child: CustomIconButtonApp(
                    onTap: onSearch,
                    color: Colors.white.withOpacity(0.2),
                    childWidget: SvgIcon(
                      iconName: 'assets/svg/client/search.svg',
                      // color: Colors.white,
                      // width: 20.w,
                      // height: 20.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile Picture (Avatar)
        PositionedDirectional(
          // top: avatarTop.clamp(MediaQuery.of(context).padding.top + 10.h, 200.h),
          top: lerpDouble(200.h, MediaQuery.of(context).padding.top + 10.h, progress+0.05)!,
          end: 24.w,
          child: Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: restaurant.logo ?? '',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(color: Colors.grey[300]),

              ),
            ),
          ),
        ),

        // Name & Info (Bottom of header)
        if (progress < 0.8)
        PositionedDirectional(
          bottom: 20.h,
          start: 24.w,
          // right: 130.w, // Leave room for avatar
          child: Opacity(
            opacity: (1 - progress * 2).clamp(0, 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  restaurant.name,
                  style: TextStyle().textColorBold(
                    fontSize: 24.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'الحد الأدنى للطلب: 25 د.ل',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 250.h;

  @override
  double get minExtent => 100.h + Get.mediaQuery.padding.top;

  @override
  bool shouldRebuild(covariant RestaurantHeaderDelegate oldDelegate) => true;
}

