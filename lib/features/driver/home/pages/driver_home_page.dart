import 'dart:async';

import 'package:avvento/core/routes/app_routes.dart';
import 'package:avvento/core/utils/logger.dart';
import 'package:avvento/core/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:avvento/core/utils/location_utils.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/order_status.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/socket_service.dart';
import '../controllers/driver_orders_controller.dart';
import '../widgets/active_order_view.dart';
import '../widgets/new_order_request_modal.dart';
import '../widgets/orders_list_bottom_sheet.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  LatLng _currentLocation = LatLng(
    LocationUtils.currentLatitude ?? 32.8872,
    LocationUtils.currentLongitude ?? 13.1913,
  );
  bool _isLoadingLocation = true;
  Timer? _locationTimer;
  final Set<String> _knownNearbyOrderIds = <String>{};
  bool _isNearbyOrdersBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
      final controller = Get.find<DriverOrdersController>();
      _knownNearbyOrderIds.addAll(controller.nearbyOrders.map((order) => order.id));
    });
    
    // Update FCM token on server
    NotificationService.instance.updateTokenOnServer();
  }

  Future<void> _openNavigationForSelectedOrder() async {
    final controller = Get.find<DriverOrdersController>();
    final selectedOrder = controller.selectedOrder;
    if (selectedOrder == null) return;

    final isPickupPhase = [
      OrderStatus.pending,
      OrderStatus.preparing,
      OrderStatus.awaitingDelivery,
    ].contains(selectedOrder.status);

    final destinationLat = isPickupPhase
        ? selectedOrder.pickupLocation.latitude
        : selectedOrder.deliveryLocation.latitude;
    final destinationLong = isPickupPhase
        ? selectedOrder.pickupLocation.longitude
        : selectedOrder.deliveryLocation.longitude;

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(destinationLat, destinationLong),
        16,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startLocationUpdates();
    } else if (state == AppLifecycleState.paused) {
      _stopLocationUpdates();
    }
  }

  void _startLocationUpdates() {
    _stopLocationUpdates();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _updateDriverLocation();
    });
  }

  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _updateDriverLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      final controller = Get.find<DriverOrdersController>();
      await controller.updateLocation(position.latitude, position.longitude);
    } catch (e) {
      cprint("error updating driver location: $e");
    }
  }

  void _initializeController() {
    if (!Get.isRegistered<SocketService>()) {
      Get.put(SocketService());
    }
    final socketService = Get.find<SocketService>();
    socketService.connectToNotifications();

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

      final controller = Get.find<DriverOrdersController>();
      
      // Update location on server
      await controller.updateLocation(position.latitude, position.longitude);
      
      // Fetch available orders via socket
      controller.emitGetAvailableOrders();

      // Fetch driver's active orders to show on map
      await controller.fetchMyOrders();

      _startLocationUpdates();
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

  void _handleNearbyOrdersUpdates(DriverOrdersController controller) {
    final currentOrderIds = controller.nearbyOrders.map((order) => order.id).toSet();
    final newOrders = controller.nearbyOrders
        .where((order) => !_knownNearbyOrderIds.contains(order.id))
        .toList();

    _knownNearbyOrderIds
      ..clear()
      ..addAll(currentOrderIds);

    if (newOrders.isEmpty) return;

    final selectedOrder = controller.selectedOrder;
    final hasSelectedNearbyOrder = selectedOrder != null &&
        controller.nearbyOrders.any((order) => order.id == selectedOrder.id);

    if (!hasSelectedNearbyOrder) {
      controller.selectOrder(newOrders.last);
    }
  }

  void _syncNearbyOrderBottomSheet(DriverOrdersController controller) {
    final selectedOrder = controller.selectedOrder;
    final isSelectedNearby = selectedOrder != null &&
        controller.nearbyOrders.any((order) => order.id == selectedOrder.id);

    if (isSelectedNearby && !_isNearbyOrdersBottomSheetOpen) {
      _showNearbyOrdersBottomSheet();
      return;
    }

    if (!isSelectedNearby &&
        _isNearbyOrdersBottomSheetOpen &&
        Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  Future<void> _showNearbyOrdersBottomSheet() async {
    if (!mounted || _isNearbyOrdersBottomSheetOpen) return;

    _isNearbyOrdersBottomSheetOpen = true;

    await Get.bottomSheet(
      Obx(() {
        final controller = Get.find<DriverOrdersController>();
        final selectedOrder = controller.selectedOrder;
        final isSelectedNearby = selectedOrder != null &&
            controller.nearbyOrders.any((order) => order.id == selectedOrder.id);

        if (!isSelectedNearby) {
          return const SizedBox.shrink();
        }

        return NewOrderRequestModal(order: selectedOrder);
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );

    _isNearbyOrdersBottomSheetOpen = false;

    if (!mounted) return;
    final controller = Get.find<DriverOrdersController>();
    final selectedOrder = controller.selectedOrder;
    final isStillNearby = selectedOrder != null &&
        controller.nearbyOrders.any((order) => order.id == selectedOrder.id);
    if (isStillNearby) {
      controller.clearSelectedOrder();
    }
  }



  @override
  Widget build(BuildContext context) {
    // return Lottie.asset(
    //   "assets/loti_files/img.json",
    //   fit: BoxFit.contain,
    //   repeat: true,
    //   options: LottieOptions(enableMergePaths: true),
    //   addRepaintBoundary: true,
    //   height: 140.h,
    // );
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
                  OrderStatus.pending,
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

          // Listen for any newly arrived nearby order and show a timed dialog.
          Obx(() {
            final controller = Get.find<DriverOrdersController>();
            controller.nearbyOrders.length;
            controller.selectedOrder;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _handleNearbyOrdersUpdates(controller);
              _syncNearbyOrderBottomSheet(controller);
            });
            return const SizedBox.shrink();
          }),

          // Top header with gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.7, 1.0],
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                ],
              ),
            ),
            padding: EdgeInsetsDirectional.only(
              start: 20.w,
              end: 20.w,
              top: MediaQuery.of(context).padding.top + 12.h,
              bottom: 20.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Right side: Availability toggle - Icon only
                Obx(() {
                  final controller = Get.find<DriverOrdersController>();
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  
                  return GestureDetector(
                    onTap: () => controller.toggleAvailability(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: 48.w,
                      height: 26.h,
                      decoration: BoxDecoration(
                        color: controller.isAvailable 
                            ? AppColors.primary
                            : isDark
                                ? const Color(0xFF1A2332)
                                : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(13.r),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ), 


                      
                      child: Stack(
                        children: [
                          AnimatedPositionedDirectional(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            start: controller.isAvailable ? 3.w : 19.w,
                            top: 3.h,
                            child: Container(
                              width: 20.w,
                              height: 20.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Center: Earnings card - without label
                Obx(() {
                  final controller = Get.find<DriverOrdersController>();
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 18.r,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '${controller.todayEarnings.toStringAsFixed(2)} د.ل',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'IBMPlexSansArabic',
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Left side: Notification icon
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.notifications);
                      },
                      borderRadius: BorderRadius.circular(100.r),
                      child: Container(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 22.r,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
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
              if (controller.selectedOrder != null) {
                return const SizedBox.shrink();
              }


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

          PositionedDirectional(
            bottom: 32.h,
            start: 16.w,
            child: Obx(() {
              final controller = Get.find<DriverOrdersController>();
              if (controller.selectedOrder == null) {
                return const SizedBox.shrink();
              }
              return Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(100.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100.r),
                  onTap: _openNavigationForSelectedOrder,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.r),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.navigation_rounded,
                          color: AppColors.primary,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'توجيه',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          // Inline panel for my active orders only
          Obx(() {
            final controller = Get.find<DriverOrdersController>();
            final selectedOrder = controller.selectedOrder;
            if (selectedOrder == null) {
              return const SizedBox.shrink();
            }

            final isMyOrder = controller.myOrders.any((o) => o.id == selectedOrder.id);
            if (!isMyOrder) {
              return const SizedBox.shrink();
            }

            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: ActiveOrderView(
                  order: selectedOrder,
                  onNavigateToOrderLocation: _openNavigationForSelectedOrder,
                ),
              ),
            );
          }),

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
    _stopLocationUpdates();
    if (_isNearbyOrdersBottomSheetOpen && Get.isBottomSheetOpen == true) {
      Get.back();
    }
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    super.dispose();
  }
}
