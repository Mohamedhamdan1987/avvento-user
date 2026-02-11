import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:avvento/core/utils/polyline_utils.dart';
import 'package:avvento/core/enums/order_status.dart';
import 'package:avvento/core/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/order_tracking_dialog.dart';

class OrderTrackingMapPage extends StatefulWidget {
  final double userLat;
  final double userLong;
  final double restaurantLat;
  final double restaurantLong;
  final String orderId;
  final OrderStatus status;
  final String? driverName;
  final String? driverPhone;
  final String? driverImageUrl;

  const OrderTrackingMapPage({
    super.key,
    required this.userLat,
    required this.userLong,
    required this.restaurantLat,
    required this.restaurantLong,
    required this.orderId,
    required this.status,
    this.driverName,
    this.driverPhone,
    this.driverImageUrl,
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
  }

  void _setupMap() {
    final userLocation = LatLng(widget.userLat, widget.userLong);
    final restaurantLocation = LatLng(widget.restaurantLat, widget.restaurantLong);

    setState(() {
      // Create markers
      _markers = {
        Marker(
          markerId: const MarkerId('user_location'),
          position: userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'موقعك الحالي',
          ),
        ),
        Marker(
          markerId: const MarkerId('restaurant_location'),
          position: restaurantLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: 'موقع المطعم',
          ),
        ),
      };
    });
  }

  Future<void> _loadRoute() async {
    final userLat = widget.userLat;
    final userLong = widget.userLong;
    final restaurantLat = widget.restaurantLat;
    final restaurantLong = widget.restaurantLong;

    try {
      // Get route polyline from Google Directions API
      final routePoints = await PolylineUtils.getRoutePolyline(
        originLat: userLat,
        originLng: userLong,
        destLat: restaurantLat,
        destLng: restaurantLong,
      );

      print('🟢 [OrderTrackingMap] Received ${routePoints.length} route points');

      if (mounted) {
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: routePoints,
              color: AppColors.primary,
              width: 5,
              geodesic: false,
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
                LatLng(userLat, userLong),
                LatLng(restaurantLat, restaurantLong),
              ],
              color: AppColors.primary,
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

    final userLat = widget.userLat;
    final userLong = widget.userLong;
    final restaurantLat = widget.restaurantLat;
    final restaurantLong = widget.restaurantLong;

    // Calculate bounds with padding
    final minLat = userLat < restaurantLat ? userLat : restaurantLat;
    final maxLat = userLat > restaurantLat ? userLat : restaurantLat;
    final minLng = userLong < restaurantLong ? userLong : restaurantLong;
    final maxLng = userLong > restaurantLong ? userLong : restaurantLong;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  void _goToOrdersPage() {
    Get.offAllNamed(AppRoutes.clientNavBar, arguments: {'tabIndex': 1});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goToOrdersPage();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          'تتبع الطلب',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => _goToOrdersPage(),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (widget.userLat + widget.restaurantLat) / 2,
                (widget.userLong + widget.restaurantLong) / 2,
              ),
              zoom: 15,
            ),
            polylines: _polylines,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            compassEnabled: true,
            zoomControlsEnabled: true,
            padding: EdgeInsets.only(bottom: 120.h),
          ),
          // Non-modal order tracking sheet - allows map interaction
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.12,
            maxChildSize: 0.92,
            snap: true,
            snapSizes: const [0.12, 0.45, 0.92],
            builder: (context, scrollController) {
              return OrderTrackingDialog(
                scrollController: scrollController,
                orderId: widget.orderId,
                status: widget.status,
                driverName: widget.driverName,
                driverPhone: widget.driverPhone,
                driverImageUrl: widget.driverImageUrl,
              );
            },
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

