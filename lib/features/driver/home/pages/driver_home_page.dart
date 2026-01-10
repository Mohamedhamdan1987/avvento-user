import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../controllers/driver_orders_controller.dart';
import '../widgets/new_order_request_modal.dart';
import '../widgets/active_order_view.dart';

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
    _getCurrentLocation();
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
      
      // Load mock orders for testing
      // TODO: Remove this in production and uncomment the API call below
      controller.loadMockOrders();
      
      // Uncomment for production:
      // await controller.fetchNearbyOrders(
      //   latitude: position.latitude,
      //   longitude: position.longitude,
      // );

      // Initialize today's earnings (TODO: Fetch from API)
      controller.setTodayEarnings(450.50);
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      Get.snackbar(
        'خطأ',
        'فشل في الحصول على الموقع الحالي',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                onMapCreated: (c) => _mapController = c,
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

          // Top header with gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.black.withOpacity(0.0),
                ],
              ),
            ),
            padding: EdgeInsetsDirectional.only(
              start: 16.w,
              end: 16.w,
              top: 48.h,
              bottom: 0,
            ),
            child: GetX<DriverOrdersController>(
              builder: (controller) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Right side: Earnings and availability (in RTL, right = start)
                    Row(
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
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.borderLightGray,
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
                                          : AppColors.borderGray,
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
                                  color: AppColors.textPlaceholder,
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
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.borderLightGray,
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
                                  color: AppColors.textPlaceholder,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${controller.todayEarnings.toStringAsFixed(2)} د.ل',
                                style: const TextStyle().textColorBold(
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Left side: Notification icon and test buttons (in RTL, left = end)
                    Row(
                      children: [
                        // Load active orders button (for testing only)
                        CustomIconButtonApp(
                          width: 40.w,
                          height: 40.h,
                          radius: 100.r,
                          color: Colors.white,
                          borderColor: AppColors.borderLightGray,
                          onTap: () {
                            controller.loadActiveMockOrders();
                            Get.snackbar(
                              'تم',
                              'تم تحميل الطلبات النشطة',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          childWidget: Icon(
                            Icons.shopping_bag,
                            size: 20.r,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Add mock order button (for testing only)
                        CustomIconButtonApp(
                          width: 40.w,
                          height: 40.h,
                          radius: 100.r,
                          color: Colors.white,
                          borderColor: AppColors.borderLightGray,
                          onTap: () {
                            controller.addMockOrder();
                            Get.snackbar(
                              'تم',
                              'تم إضافة طلب تجريبي جديد',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          childWidget: Icon(
                            Icons.add,
                            size: 20.r,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        CustomIconButtonApp(
                          width: 40.w,
                          height: 40.h,
                          radius: 100.r,
                          color: Colors.white,
                          borderColor: AppColors.borderLightGray,
                          onTap: () {
                            // TODO: Navigate to notifications
                          },
                          childWidget: Icon(
                            Icons.notifications_outlined,
                            size: 20.r,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // Show active order view if there's an active order
          GetX<DriverOrdersController>(
            builder: (controller) {
              // Check if there's an active order (not delivered or cancelled)
              final activeOrder = controller.myOrders.firstWhereOrNull(
                (order) => !['delivered', 'cancelled'].contains(order.status.toLowerCase()),
              );

              if (activeOrder != null) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ActiveOrderView(order: activeOrder),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          // Show modal when order is selected from map marker (only if no active order)
          GetX<DriverOrdersController>(
            builder: (controller) {
              // Don't show if there's an active order
              final hasActiveOrder = controller.myOrders.any(
                (order) => !['delivered', 'cancelled'].contains(order.status.toLowerCase()),
              );

              if (controller.selectedOrder != null && !hasActiveOrder) {
                // Show modal bottom sheet when order is selected
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Get.isBottomSheetOpen == false) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      isDismissible: true,
                      enableDrag: true,
                      builder: (context) => NewOrderRequestModal(
                        order: controller.selectedOrder!,
                      ),
                    ).then((_) {
                      // Clear selection when modal is dismissed
                      controller.clearSelectedOrder();
                    });
                  }
                });
              }

              return const SizedBox.shrink();
            },
          ),

          // Show empty state if no orders (only when no order is selected and no active order)
          GetX<DriverOrdersController>(
            builder: (controller) {
              final hasActiveOrder = controller.myOrders.any(
                (order) => !['delivered', 'cancelled'].contains(order.status.toLowerCase()),
              );

              if (controller.selectedOrder == null &&
                  !hasActiveOrder &&
                  controller.nearbyOrders.isEmpty &&
                  !controller.isLoading) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: EdgeInsets.all(16.w),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                          color: AppColors.textMedium,
                          size: 24.r,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'لا توجد طلبات قريبة حالياً',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          // Loading indicator for location
          if (_isLoadingLocation)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                          color: AppColors.textDark,
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
