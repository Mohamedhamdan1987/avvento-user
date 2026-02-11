import 'package:avvento/core/enums/order_status.dart';
import 'package:avvento/core/utils/logger.dart';
import 'package:avvento/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../models/driver_order_model.dart';
import '../models/driver_dashboard_model.dart';
import '../services/driver_orders_service.dart';
import '../widgets/active_order_view.dart';
import '../widgets/new_order_request_modal.dart';

class DriverOrdersController extends GetxController {
  final DriverOrdersService _ordersService = DriverOrdersService();

  final RxList<DriverOrderModel> _nearbyOrders = <DriverOrderModel>[].obs;
  final RxList<DriverOrderModel> _myOrders = <DriverOrderModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isAccepting = false.obs;
  final Rx<DriverOrderModel?> _selectedOrder = Rx<DriverOrderModel?>(null);
  final RxSet<Marker> _markers = <Marker>{}.obs;
  final RxBool _isAvailable = false.obs;
  final RxDouble _todayEarnings = 0.0.obs;
  final RxBool _showActiveOrders = true.obs;
  final RxInt _activeOrderPageIndex = 0.obs;
  final Rx<DriverDashboardModel?> _dashboardData = Rx<DriverDashboardModel?>(null);

  List<DriverOrderModel> get nearbyOrders => _nearbyOrders;
  List<DriverOrderModel> get myOrders => _myOrders;
  bool get isLoading => _isLoading.value;
  bool get isAccepting => _isAccepting.value;
  DriverOrderModel? get selectedOrder => _selectedOrder.value;
  Set<Marker> get markers => _markers;
  bool get isAvailable => _isAvailable.value;
  double get todayEarnings => _todayEarnings.value;
  bool get showActiveOrders => _showActiveOrders.value;
  int get activeOrderPageIndex => _activeOrderPageIndex.value;
  DriverDashboardModel? get dashboardData => _dashboardData.value;

  // Toggle driver availability
  Future<void> toggleAvailability() async {
    final currentStatus = _isAvailable.value;
    final isStoppingWork = currentStatus;

    // Get theme detection
    final isDarkMode = Get.isDarkMode;
    final dialogBg = isDarkMode ? const Color(0xFF0B0E13) : Colors.white;
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF101828);
    final textSecondary =
        isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF4A5565);
    final infoBgColor =
        isDarkMode ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    final infoBorderColor =
        isDarkMode ? const Color(0xFF1E2A3A) : const Color(0xFFE5E7EB);
    final outlineButtonColor =
        isDarkMode ? const Color(0xFF1E2A3A) : const Color(0xFFE5E7EB);

    // Show enhanced confirmation dialog with dark theme support
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: dialogBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon and title
              Container(
                decoration: BoxDecoration(
                  color: (isStoppingWork
                          ? AppColors.error
                          : AppColors.primary)
                      .withOpacity(isDarkMode ? 0.15 : 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isStoppingWork ? AppColors.error : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isStoppingWork ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      'تأكيد تغيير الحالة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (isStoppingWork
                                ? AppColors.error
                                : AppColors.primary)
                            .withOpacity(isDarkMode ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isStoppingWork ? 'التوقف عن العمل' : 'بدء العمل',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isStoppingWork ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Message
                    Text(
                      isStoppingWork
                          ? 'هل أنت متأكد أنك تريد التوقف عن العمل؟'
                          : 'هل أنت متأكد أنك تريد بدء العمل؟',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Additional info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: infoBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: infoBorderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: isStoppingWork ? AppColors.error : AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isStoppingWork
                                  ? 'لن تتلقى أي طلبات جديدة أثناء توقفك'
                                  : 'ستبدأ بتلقي طلبات جديدة الآن',
                              style: TextStyle(
                                fontSize: 13,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: outlineButtonColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Confirm button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back(); // Close dialog
                          // Proceed with toggle
                          _isAvailable.value = !_isAvailable.value;
                          try {
                            final result =
                                await _ordersService.toggleWorkingStatus();

                            if (result.success && result.data != null) {
                              final newStatus = result.data!['newStatus'] as String;
                              _isAvailable.value = newStatus == 'working';

                              final message = result.data!['message'] as String? ??
                                  (newStatus == 'working'
                                      ? 'أنت الآن في وضع العمل - سيتم إرسال الطلبات الجديدة لك'
                                      : 'أنت الآن متوقف - لن تتلقى طلبات جديدة');

                              showSnackBar(
                                message: message,
                                isSuccess: true,
                              );
                            } else {
                              // Revert on failure
                              _isAvailable.value = !_isAvailable.value;
                              showSnackBar(
                                title: 'خطأ',
                                message: result.message ?? 'فشل في تغيير حالة العمل',
                              );
                            }
                          } catch (e) {
                            // Revert on error
                            _isAvailable.value = !_isAvailable.value;
                            showSnackBar(
                              title: 'خطأ',
                              message: 'حدث خطأ غير متوقع: ${e.toString()}',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isStoppingWork
                              ? AppColors.error
                              : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          isStoppingWork ? 'نعم، توقف' : 'نعم، ابدأ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Toggle active orders visibility
  void toggleActiveOrdersVisibility() {
    _showActiveOrders.value = !_showActiveOrders.value;
  }

  // Set active order page index
  void setActiveOrderPageIndex(int index) {
    _activeOrderPageIndex.value = index;
  }

  // Set today's earnings
  void setTodayEarnings(double earnings) {
    _todayEarnings.value = earnings;
  }

  // Fetch nearby orders based on driver's location
  Future<void> fetchNearbyOrders({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading.value = true;
    });
    try {
      final result = await _ordersService.getNearbyOrders(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );

      if (result.success && result.data != null) {
        _nearbyOrders.value = result.data!;
        _updateMarkers();
      } else {
        // Fallback to mock data if API fails during development, but show error
        // loadMockOrders(); 
        showSnackBar(
          title: 'خطأ',
          message: result.message ?? 'فشل في جلب الطلبات القريبة',
        );
      }
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Fetch driver's assigned orders
  Future<void> fetchMyOrders({String? status}) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading.value = true;
    });
    try {
      final result = await _ordersService.getMyOrders(status: status);

      if (result.success && result.data != null) {
        _myOrders.value = result.data!;
        _updateMarkers();
      } else {
        showSnackBar(
          title: 'خطأ',
          message: result.message ?? 'فشل في جلب طلباتي',
        );
      }
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Fetch dashboard data
  Future<void> fetchDashboardData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading.value = true;
    });
    try {
      final result = await _ordersService.getDashboardData();

      if (result.success && result.data != null) {
        _dashboardData.value = result.data!;
      } else {
        showSnackBar(
          title: 'خطأ',
          message: result.message ?? 'فشل في جلب بيانات لوحة التحكم',
        );
      }
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Accept an order
  Future<void> acceptOrder(String orderId) async {
    _isAccepting.value = true;
    try {
      final result = await _ordersService.acceptOrder(orderId);

      if (result.success && result.data != null) {
        // Remove from nearby orders
        _nearbyOrders.removeWhere((order) => order.id == orderId);
        // Add to my orders
        _myOrders.add(result.data!);
        _updateMarkers();
        
        showSnackBar(
          message: 'تم قبول الطلب بنجاح، بالتوفيق في التوصيل!',
          isSuccess: true,
        );
        
        // Close bottom sheet
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.back();
        });
      } else {
        showSnackBar(
          title: 'خطأ',
          message: result.message ?? 'فشل في قبول الطلب',
        );
      }
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    } finally {
      _isAccepting.value = false;
    }
  }

  // Reject an order
  Future<void> rejectOrder(String orderId) async {
    try {
      final result = await _ordersService.rejectOrder(orderId);

      if (result.success) {
        // Remove from nearby orders
        _nearbyOrders.removeWhere((order) => order.id == orderId);
        _updateMarkers();
        
        showSnackBar(
          title: 'تم',
          message: 'تم رفض الطلب',
        );
        
        // Close bottom sheet
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.back();
        });
      } else {
        showSnackBar(
          title: 'خطأ',
          message: result.message ?? 'فشل في رفض الطلب',
        );
      }
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }

  // Update order status
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final result = await _ordersService.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      if (result.success && result.data != null) {
        // Update in my orders list
        final index = _myOrders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _myOrders[index] = result.data!;
        }
        
        showSnackBar(
          message: 'تم تحديث حالة الطلب بنجاح',
          isSuccess: true,
        );
        fetchMyOrders();
      } else {
        showSnackBar(
          title: 'خطأ',
          message: result.message ?? 'فشل في تحديث حالة الطلب',
        );
      }
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }

  // Select an order to view details
  void selectOrder(DriverOrderModel order) {
    _selectedOrder.value = order;
    
    // Check if it's one of my active orders
    final isMyOrder = _myOrders.any((o) => o.id == order.id);

    // Open bottom sheet when order is selected
    // Using GetX navigation to avoid build context issues
    if (Get.isBottomSheetOpen == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.bottomSheet(
          isMyOrder ? ActiveOrderView(order: order) : NewOrderRequestModal(order: order),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: true,
          isDismissible: true,
        ).then((_) {
          // Clear selection when modal is dismissed
          _selectedOrder.value = null;
        });
      });
    }
  }

  // Clear selected order
  void clearSelectedOrder() {
    _selectedOrder.value = null;
    // Close any open bottom sheets
    if (Get.isBottomSheetOpen == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
    }
  }

  // Update driver location
  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      final result = await _ordersService.updateDriverLocation(
        latitude: latitude,
        longitude: longitude,
      );

      if (!result.success) {
        cprint('Failed to update location: ${result.message}');
      }
    } catch (e) {
      cprint('Error updating location: $e');
    }
  }

  // Update map markers for nearby orders and my active orders
  void _updateMarkers() {
    _markers.clear();
    
    // 1. Add markers for nearby available orders (RED) - at pickup location
    for (var order in _nearbyOrders) {
      _markers.add(
        Marker(
          markerId: MarkerId('nearby_${order.id}'),
          position: LatLng(
            order.pickupLocation.latitude,
            order.pickupLocation.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'طلب متاح #${order.orderNumber}',
            snippet: 'المطعم: ${order.restaurantName}',
          ),
          onTap: () {
            selectOrder(order);
          },
        ),
      );
    }

    // 2. Add markers for my current active orders
    for (var order in _myOrders) {
      // Skip delivered or cancelled orders
      if ([OrderStatus.delivered, OrderStatus.cancelled].contains(order.status)) continue;

      // Determine marker position based on status
      // If we haven't picked up yet, show pickup location. If on the way, show delivery location.
      bool isPickupPhase = [
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.awaitingDelivery
      ].contains(order.status);
      
      LatLng markerPosition = isPickupPhase 
          ? LatLng(order.pickupLocation.latitude, order.pickupLocation.longitude)
          : LatLng(order.deliveryLocation.latitude, order.deliveryLocation.longitude);

      // Blue for pickup, Green for delivery
      double hue = isPickupPhase ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueGreen;
      String phaseTitle = isPickupPhase ? 'استلام من المطعم' : 'تسليم للعميل';
      String targetName = isPickupPhase ? order.restaurantName : order.customerName;

      _markers.add(
        Marker(
          markerId: MarkerId('my_${order.id}'),
          position: markerPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: 'طلبي #${order.orderNumber} ($phaseTitle)',
            snippet: 'الوجهة: $targetName',
          ),
          onTap: () {
            selectOrder(order);
          },
        ),
      );
    }
    
    // Ensure update() is called after build if triggered during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize controller
  }

  @override
  void onClose() {
    // Clean up
    super.onClose();
  }
}
