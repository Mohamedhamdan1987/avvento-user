import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../models/driver_order_model.dart';
import '../services/driver_orders_service.dart';
import '../data/mock_orders_data.dart';

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

  List<DriverOrderModel> get nearbyOrders => _nearbyOrders;
  List<DriverOrderModel> get myOrders => _myOrders;
  bool get isLoading => _isLoading.value;
  bool get isAccepting => _isAccepting.value;
  DriverOrderModel? get selectedOrder => _selectedOrder.value;
  Set<Marker> get markers => _markers;
  bool get isAvailable => _isAvailable.value;
  double get todayEarnings => _todayEarnings.value;

  // Toggle driver availability
  void toggleAvailability() {
    _isAvailable.value = !_isAvailable.value;
    // TODO: Send availability status to backend
  }

  // Set today's earnings
  void setTodayEarnings(double earnings) {
    _todayEarnings.value = earnings;
  }

  // Load mock orders for testing
  void loadMockOrders() {
    _nearbyOrders.value = MockOrdersData.getMockOrders();
    _updateMarkers();
  }

  // Add a single mock order for testing
  void addMockOrder() {
    final mockOrder = MockOrdersData.getSingleMockOrder();
    // Create a new order with unique ID
    final newOrder = DriverOrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      customerId: mockOrder.customerId,
      customerName: mockOrder.customerName,
      customerPhone: mockOrder.customerPhone,
      restaurantId: mockOrder.restaurantId,
      restaurantName: mockOrder.restaurantName,
      pickupLocation: mockOrder.pickupLocation,
      deliveryLocation: mockOrder.deliveryLocation,
      items: mockOrder.items,
      totalAmount: mockOrder.totalAmount,
      paymentMethod: mockOrder.paymentMethod,
      status: mockOrder.status,
      createdAt: DateTime.now(),
      deliveryFee: mockOrder.deliveryFee,
      notes: mockOrder.notes,
    );
    _nearbyOrders.add(newOrder);
    _updateMarkers();
  }

  // Load active orders with different statuses for testing
  void loadActiveMockOrders() {
    _myOrders.value = MockOrdersData.getActiveMockOrders();
    update();
  }

  // Load a specific active order by status for testing
  void loadActiveOrderByStatus(String status) {
    final order = MockOrdersData.getActiveOrderByStatus(status);
    _myOrders.value = [order];
    update();
  }

  // Add an active order with specific status for testing
  void addActiveOrderByStatus(String status) {
    final order = MockOrdersData.getActiveOrderByStatus(status);
    // Create a new order with unique ID
    final newOrder = DriverOrderModel(
      id: 'active_order_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      restaurantId: order.restaurantId,
      restaurantName: order.restaurantName,
      pickupLocation: order.pickupLocation,
      deliveryLocation: order.deliveryLocation,
      items: order.items,
      totalAmount: order.totalAmount,
      paymentMethod: order.paymentMethod,
      status: status,
      createdAt: DateTime.now(),
      deliveryFee: order.deliveryFee,
      notes: order.notes,
    );
    _myOrders.add(newOrder);
    update();
  }

  // Fetch nearby orders based on driver's location
  Future<void> fetchNearbyOrders({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    _isLoading.value = true;
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
    _isLoading.value = true;
    try {
      final result = await _ordersService.getMyOrders(status: status);

      if (result.success && result.data != null) {
        _myOrders.value = result.data!;
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
          title: 'نجح',
          message: 'تم قبول الطلب بنجاح',
        );
        
        // Close bottom sheet
        Get.back();
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
        Get.back();
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
          title: 'نجح',
          message: 'تم تحديث حالة الطلب',
        );
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
  }

  // Clear selected order
  void clearSelectedOrder() {
    _selectedOrder.value = null;
    // Close any open bottom sheets
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  // Update map markers for nearby orders
  void _updateMarkers() {
    _markers.clear();
    
    for (var order in _nearbyOrders) {
      // Add marker for delivery location
      _markers.add(
        Marker(
          markerId: MarkerId(order.id),
          position: LatLng(
            order.deliveryLocation.latitude,
            order.deliveryLocation.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'طلب #${order.orderNumber}',
            snippet: order.deliveryLocation.address,
          ),
          onTap: () {
            selectOrder(order);
          },
        ),
      );
      update();
    }
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
