import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/utils/polyline_utils.dart';
import 'package:avvento/core/enums/order_status.dart';
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
    // Open order tracking dialog automatically after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _openTrackingDialog();
        }
      });
    });
  }

  void _openTrackingDialog() {
    OrderTrackingDialog.show(
      context,
      widget.orderId,
      widget.status,
      driverName: widget.driverName,
      driverPhone: widget.driverPhone,
      driverImageUrl: widget.driverImageUrl,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ),
          // Reopen Tracking Dialog Button
          Positioned(
            bottom: 24.h,
            left: 24.w,
            right: 24.w,
            child: GestureDetector(
              onTap: () => _openTrackingDialog(),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: SvgIcon(
                          iconName: 'assets/svg/client/orders/on_the_way.svg',
                          width: 24.w,
                          height: 24.h,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تفاصيل الطلب',
                            style: TextStyle().textColorBold(
                              fontSize: 14.sp,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'اضغط لعرض حالة الطلب والتفاصيل',
                            style: TextStyle().textColorNormal(
                              fontSize: 12.sp,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: AppColors.primary,
                      size: 28.sp,
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

