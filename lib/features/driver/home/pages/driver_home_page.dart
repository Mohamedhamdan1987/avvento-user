import 'package:avvento/core/routes/app_routes.dart';
import 'package:avvento/core/utils/logger.dart';
import 'package:avvento/core/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/order_status.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../controllers/driver_orders_controller.dart';
import '../widgets/orders_list_bottom_sheet.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(32.8872, 13.1913); // Default Tripoli
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
    
    // Update FCM token on server
    NotificationService.instance.updateTokenOnServer();
  }

  void _initializeController() {
    if (!Get.isRegistered<DriverOrdersController>()) {
      Get.put(DriverOrdersController());
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 14),
      );

      // Fetch nearby orders
      final controller = Get.find<DriverOrdersController>();
      
      // Update location on server
      await controller.updateLocation(position.latitude, position.longitude);
      
      // Load real orders from API
      await controller.fetchNearbyOrders(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Fetch driver's active orders to show on map
      await controller.fetchMyOrders();

      // Initialize today's earnings (TODO: Fetch from API)
      // controller.setTodayEarnings(0.0);
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocation = false);
      cprint("error in get location: $e");
      showSnackBar(
        title: 'خطأ',
        message: 'فشل في الحصول على الموقع الحالي',
        isError: true,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Google Map
          GetBuilder<DriverOrdersController>(
            builder: (controller) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLocation,
                  zoom: 14,
                ),
                onMapCreated: (c) {
                  _mapController = c;
                  // TODO: Set map style for dark mode if needed
                  // if (Theme.of(context).brightness == Brightness.dark) {
                  //   c.setMapStyle(darkMapStyle);
                  // }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                markers: controller.markers,
                onTap: (_) {
                  // Dismiss any open bottom sheets
                  controller.clearSelectedOrder();
                },
              );
            },
          ),

          // Listener for order selection to animate camera
          GetX<DriverOrdersController>(
            builder: (controller) {
              final selectedOrder = controller.selectedOrder;
              if (selectedOrder != null) {
                // Determine target location (pickup or delivery based on status)
                bool isPickupPhase = [
                  OrderStatus.confirmed,
                  OrderStatus.preparing,
                  OrderStatus.awaitingDelivery
                ].contains(selectedOrder.status);

                LatLng targetLocation = isPickupPhase
                    ? LatLng(selectedOrder.pickupLocation.latitude, selectedOrder.pickupLocation.longitude)
                    : LatLng(selectedOrder.deliveryLocation.latitude, selectedOrder.deliveryLocation.longitude);

                // Delay slightly to ensure map is ready and avoid animation conflicts
                Future.delayed(const Duration(milliseconds: 300), () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(targetLocation, 15),
                  );
                });
              }
              return const SizedBox.shrink();
            },
          ),

          // Top header with gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                ],
              ),
            ),
            padding: EdgeInsetsDirectional.only(
              start: 16.w,
              end: 16.w,
              top: 48.h,
              bottom: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Right side: Earnings and availability
                Obx(() {
                  final controller = Get.find<DriverOrdersController>();
                  return Row(
                    children: [
                      // Availability toggle
                      Container(
                        padding: EdgeInsetsDirectional.only(
                          start: 0.76.w,
                          end: 8.75.w,
                          top: 0.76.h,
                          bottom: 0.76.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 0.76.w,
                          ),
                          borderRadius: BorderRadius.circular(100.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => controller.toggleAvailability(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 39.w,
                                height: 18.h,
                                decoration: BoxDecoration(
                                  color: controller.isAvailable
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(100.r),
                                  border: Border.all(
                                    color: controller.isAvailable
                                        ? AppColors.primary
                                        : Theme.of(context).dividerColor,
                                    width: 0.76.w,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    AnimatedPositionedDirectional(
                                      duration: const Duration(milliseconds: 200),
                                      start: controller.isAvailable ? 0.49.w : 21.23.w,
                                      top: 0.49.h,
                                      child: Container(
                                        width: 16.w,
                                        height: 16.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              controller.isAvailable ? 'متاح' : 'غير متاح',
                              style: const TextStyle().textColorBold(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPlaceholder,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Earnings card
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 0.76.w,
                          ),
                          borderRadius: BorderRadius.circular(100.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'أرباح اليوم',
                              style: const TextStyle().textColorNormal(
                                fontSize: 10,
                                color: AppColors.textPlaceholder, // Keep placeholder color or use hintColor
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${controller.todayEarnings.toStringAsFixed(2)} د.ل',
                              style: const TextStyle().textColorBold(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),

                // Left side: Notification icon
                CustomIconButtonApp(
                  width: 40.w,
                  height: 40.h,
                  radius: 100.r,
                  color: Theme.of(context).cardColor,
                  borderColor: Theme.of(context).dividerColor,
                  onTap: () {
                    Get.toNamed(AppRoutes.notifications);

                  },
                  childWidget: Icon(
                    Icons.notifications_outlined,
                    size: 20.r,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ],
            ),
          ),



          // Floating list buttons
          PositionedDirectional(
            bottom: 32.h,
            end: 16.w,
            child: Obx(() {
              final controller = Get.find<DriverOrdersController>();


              return Column(
                children: [
                  // My Orders Button
                  _buildFloatingListButton(
                    context,
                    icon: Icons.assignment_outlined,
                    label: 'طلباتي',
                    onTap: () {
                      Get.bottomSheet(
                        OrdersListBottomSheet(
                          title: 'طلباتي المعينة',
                          orders: controller.myOrders,
                        ),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                    },
                    count: controller.myOrders.length,
                  ),
                  SizedBox(height: 16.h),
                  // Nearby Orders Button
                  _buildFloatingListButton(
                    context,
                    icon: Icons.near_me_outlined,
                    label: 'طلبات قريبة',
                    onTap: () {
                      Get.bottomSheet(
                        OrdersListBottomSheet(
                          title: 'طلبات قريبة متاحة',
                          orders: controller.nearbyOrders,
                          isNearby: true,
                        ),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                    },
                    count: controller.nearbyOrders.length,
                    isPrimary: true,
                  ),
                ],
              );
            }),
          ),

          // Modal is now triggered directly from DriverOrdersController.selectOrder using Get.bottomSheet

          // Show empty state if no orders (only when no order is selected and no active order)
          Obx(() {
            final controller = Get.find<DriverOrdersController>();
            final hasActiveOrder = controller.myOrders.any(
              (order) => !['delivered', 'cancelled'].contains(order.status.toString().toLowerCase()),
            );

            if (
            controller.selectedOrder == null &&
                !hasActiveOrder &&
                controller.nearbyOrders.isEmpty &&
                !controller.isLoading)
            {

              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).hintColor,
                        size: 24.r,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'لا توجد طلبات قريبة حالياً',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          }),

          // Loading indicator for location
          if (_isLoadingLocation)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'جاري تحديد موقعك...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingListButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int count,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: isPrimary ? AppColors.primary : Theme.of(context).dividerColor,
            width: 0.76.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count > 0) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isPrimary ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: isPrimary ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              icon,
              size: 20.r,
              color: isPrimary ? Colors.white : Theme.of(context).iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
