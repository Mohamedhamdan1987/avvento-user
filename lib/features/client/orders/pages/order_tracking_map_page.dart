import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/utils/polyline_utils.dart';
import 'package:avvento/core/enums/order_status.dart';
import '../widgets/order_tracking_dialog.dart';

class OrderTrackingMapPage extends StatefulWidget {
  final double userLat;
  final double userLong;
  final double restaurantLat;
  final double restaurantLong;
  final String orderId;
  final OrderStatus status;

  const OrderTrackingMapPage({
    super.key,
    required this.userLat,
    required this.userLong,
    required this.restaurantLat,
    required this.restaurantLong,
    required this.orderId,
    required this.status,
  });

  @override
  State<OrderTrackingMapPage> createState() => _OrderTrackingMapPageState();
}

class _OrderTrackingMapPageState extends State<OrderTrackingMapPage> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setupMap();
    _loadRoute();
    // Open order tracking dialog automatically after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          OrderTrackingDialog.show(
            context,
            widget.orderId,
            widget.status,
          );
        }
      });
    });
  }

  void _setupMap() {
    // Test coordinates - two points close to each other in Tripoli, Libya
    // Point 1: User location (test)
    final testUserLat = 32.8872;
    final testUserLong = 13.1913;
    
    // Point 2: Restaurant location (test) - about 1 km away
    final testRestaurantLat = 32.8950;
    final testRestaurantLong = 13.2000;
    
    // Use test coordinates for now (you can replace with actual coordinates later)
    final userLocation = LatLng(testUserLat, testUserLong);
    final restaurantLocation = LatLng(testRestaurantLat, testRestaurantLong);
    
    // TODO: Replace test coordinates with actual coordinates:
    // final userLocation = LatLng(widget.userLat, widget.userLong);
    // final restaurantLocation = LatLng(widget.restaurantLat, widget.restaurantLong);

    setState(() {
      // Create markers
      _markers = {
        Marker(
          markerId: const MarkerId('user_location'),
          position: userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'موقعك الحالي (اختبار)',
          ),
        ),
        Marker(
          markerId: const MarkerId('restaurant_location'),
          position: restaurantLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: 'موقع المطعم (اختبار)',
          ),
        ),
      };
    });
  }

  Future<void> _loadRoute() async {
    // Test coordinates
    final testUserLat = 32.8872;
    final testUserLong = 13.1913;
    final testRestaurantLat = 32.8950;
    final testRestaurantLong = 13.2000;
    
    // TODO: Replace test coordinates with actual coordinates:
    // final userLat = widget.userLat;
    // final userLong = widget.userLong;
    // final restaurantLat = widget.restaurantLat;
    // final restaurantLong = widget.restaurantLong;

    try {
      // Get route polyline from Google Directions API
      final routePoints = await PolylineUtils.getRoutePolyline(
        originLat: testUserLat,
        originLng: testUserLong,
        destLat: testRestaurantLat,
        destLng: testRestaurantLong,
      );

      print('🟢 [OrderTrackingMap] Received ${routePoints.length} route points');
      print('🟢 [OrderTrackingMap] First point: ${routePoints.first}');
      print('🟢 [OrderTrackingMap] Last point: ${routePoints.last}');

      if (mounted) {
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: routePoints,
              color: const Color(0xFF7F22FE),
              width: 5,
              geodesic: false, // Set to false when using actual route
              jointType: JointType.round,
            ),
          };
        });
        
        // Update camera to fit the route after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _mapController != null) {
            _fitBounds();
          }
        });
      }
    } catch (e) {
      print('❌ [OrderTrackingMap] Error loading route: $e');
      // If route loading fails, use straight line as fallback
      if (mounted) {
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: [
                LatLng(testUserLat, testUserLong),
                LatLng(testRestaurantLat, testRestaurantLong),
              ],
              color: const Color(0xFF7F22FE),
              width: 5,
              geodesic: true,
              jointType: JointType.round,
            ),
          };
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    // Wait a bit for the map to be fully initialized
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Fit bounds to show both markers
    _fitBounds();
  }

  void _fitBounds() {
    if (_mapController == null) return;

    // Test coordinates - same as in _setupMap
    final testUserLat = 32.8872;
    final testUserLong = 13.1913;
    final testRestaurantLat = 32.8950;
    final testRestaurantLong = 13.2000;

    // Calculate bounds with padding
    final minLat = testUserLat < testRestaurantLat
        ? testUserLat
        : testRestaurantLat;
    final maxLat = testUserLat > testRestaurantLat
        ? testUserLat
        : testRestaurantLat;
    final minLng = testUserLong < testRestaurantLong
        ? testUserLong
        : testRestaurantLong;
    final maxLng = testUserLong > testRestaurantLong
        ? testUserLong
        : testRestaurantLong;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0), // Reduced padding for better view
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('تتبع الطلب', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                // Test coordinates center
                (32.8872 + 32.8950) / 2,
                (13.1913 + 13.2000) / 2,
              ),
              zoom: 15, // Increased zoom to see route details better
            ),
            polylines: _polylines,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            compassEnabled: true,
            zoomControlsEnabled: true,
          ),
          // Info Card
          Positioned(
            bottom: 24.h,
            left: 24.w,
            right: 24.w,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F22FE).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: SvgIcon(
                        iconName: 'assets/svg/client/orders/on_the_way.svg',
                        width: 24.w,
                        height: 24.h,
                        color: const Color(0xFF7F22FE),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مسار التوصيل',
                          style: TextStyle().textColorBold(
                            fontSize: 14.sp,
                            color: const Color(0xFF101828),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'الخط الأرجواني يوضح المسار بين موقعك والمطعم',
                          style: TextStyle().textColorNormal(
                            fontSize: 12.sp,
                            color: const Color(0xFF6A7282),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

