import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/location_utils.dart';

class AddressSelectionPage extends StatefulWidget {
  const AddressSelectionPage({super.key});

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(32.8872, 13.1913);
  String _addressText = '';
  bool _isMapMoving = false;
  bool _isGeocodingLoading = false;
  bool _showDetails = false;
  int _selectedTypeIndex = -1;
  bool _isInCoverage = false;
  _CoverageZone? _activeCoverageZone;
  final _detailsController = TextEditingController();
  final DioClient _dioClient = DioClient.instance;
  late List<_CoverageZone> _coverageZones;

  static const _defaultZoom = 15.0;
  static const Color _coveragePurple = Color(0xFF7C3AED);
  static const List<_CoverageZone> _fallbackCoverageZones = [
    // Add any number of coordinates; vertices count is inferred automatically.
    _CoverageZone(
      name: 'طرابلس',
      levelKey: 'city',
      coordinates: [
        LatLng(32.901836111116594, 13.220181350848666),
        LatLng(32.8964850614205, 13.22176921858591),  // نقطة مضافة
        LatLng(32.89113401172441, 13.223357086323151),
        LatLng(32.8882690425427, 13.22301376356913),  // نقطة مضافة
        LatLng(32.88540407336098, 13.222670440815108),
        LatLng(32.87843007247777, 13.21876514448875), // نقطة مضافة
        LatLng(32.871456071594565, 13.214859848162403),
        LatLng(32.87093342785582, 13.21082580580292), // نقطة مضافة
        LatLng(32.87041078411707, 13.206791763443437),
        LatLng(32.86759999999999, 13.19085776611300), // نقطة مضافة
        LatLng(32.86478921899622, 13.174923768782573),
        LatLng(32.87378265172749, 13.16403565350047), // نقطة مضافة
        LatLng(32.88277608445877, 13.153147538218379),
        LatLng(32.89244765560777, 13.16448557561957), // نقطة مضافة
        LatLng(32.90211922675678, 13.175823613020762),
        LatLng(32.89841707789204, 13.18338230462155), // نقطة مضافة
        LatLng(32.89471492902731, 13.19094099622235),
        LatLng(32.89826597583353, 13.20542848845720), // نقطة مضافة
        LatLng(32.90181702263975, 13.219915980692063),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _coverageZones = List<_CoverageZone>.from(_fallbackCoverageZones);
    _loadCoverageZonesFromApi();
    _initLocation();
  }

  Future<void> _loadCoverageZonesFromApi() async {
    try {
      final response = await _dioClient.get(
        '/app-settings/limited-area-google-map-location',
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return;

      final rawPoints = data['limitedAreaGoogleMapLocation'];
      if (rawPoints is! List) return;

      final points = <LatLng>[];
      for (final point in rawPoints) {
        if (point is! Map) continue;
        final lat = _toDouble(point['lat']);
        final lng = _toDouble(point['long']);
        if (lat != null && lng != null) {
          points.add(LatLng(lat, lng));
        }
      }

      if (points.length < 3 || !mounted) return;

      setState(() {
        _coverageZones = [
          _CoverageZone(
            name: 'طرابلس',
            levelKey: 'city',
            coordinates: points,
          ),
        ];
      });

      await _reverseGeocode(_selectedLocation);
    } catch (_) {
      // Keep fallback coverage zone when API request fails.
    }
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> _initLocation() async {
    try {
      if (LocationUtils.isInitialized &&
          LocationUtils.currentLatitude != null &&
          LocationUtils.currentLongitude != null) {
        final newLoc = LatLng(
          LocationUtils.currentLatitude!,
          LocationUtils.currentLongitude!,
        );
        setState(() => _selectedLocation = newLoc);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newLoc, _defaultZoom),
        );
        _reverseGeocode(newLoc);
      } else {
        await LocationUtils.ensureLocationPermission();
        if (LocationUtils.currentLatitude != null &&
            LocationUtils.currentLongitude != null) {
          final newLoc = LatLng(
            LocationUtils.currentLatitude!,
            LocationUtils.currentLongitude!,
          );
          if (mounted) {
            setState(() => _selectedLocation = newLoc);
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(newLoc, _defaultZoom),
            );
          }
          _reverseGeocode(newLoc);
        } else {
          _reverseGeocode(_selectedLocation);
        }
      }
    } catch (_) {
      _reverseGeocode(_selectedLocation);
    }
  }

  Future<void> _reverseGeocode(LatLng location) async {
    if (_isGeocodingLoading) return;
    _isGeocodingLoading = true;
    final coverageZone = _findCoverageZone(location);
    final isInCoverage = coverageZone != null;
    if (mounted) setState(() {});
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality!,
          if (p.street != null && p.street!.isNotEmpty) p.street!,
        ];
        setState(() {
          _addressText = parts.isNotEmpty
              ? parts.join(' - ')
              : 'طرابلس, حي الأندلس - شارع عبدالرحمن';
          _activeCoverageZone = coverageZone;
          _isInCoverage = isInCoverage;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _addressText = 'لم يتم التعرف على العنوان';
          _activeCoverageZone = coverageZone;
          _isInCoverage = isInCoverage;
        });
      }
    } finally {
      _isGeocodingLoading = false;
      if (mounted) setState(() {});
    }
  }

  _CoverageZone? _findCoverageZone(LatLng location) {
    for (final zone in _coverageZones) {
      if (zone.verticesCount >= 3 &&
          _isPointInPolygon(location, zone.polygonPoints)) {
        return zone;
      }
    }
    return null;
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;
    bool isInside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      final yi = polygon[i].latitude;
      final xi = polygon[i].longitude;
      final yj = polygon[j].latitude;
      final xj = polygon[j].longitude;

      final hasIntersection =
          ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude <
              (xj - xi) * (point.latitude - yi) / ((yj - yi) + 0.0000000001) +
                  xi);

      if (hasIntersection) isInside = !isInside;
      j = i;
    }

    return isInside;
  }

  void _goToMyLocation() async {
    try {
      final hasPermission = await LocationUtils.ensureLocationPermission();
      if (hasPermission && mounted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        final loc = LatLng(position.latitude, position.longitude);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(loc, _defaultZoom),
        );
      }
    } catch (_) {}
  }

  Future<void> _openNavigationToSelectedLocation() async {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedLocation, _defaultZoom + 2),
    );
  }

  void _continueAsGuest() {
    final storage = GetStorage();
    storage.write(AppConstants.onboardingSeenKey, true);
    if (_addressText.isNotEmpty) {
      storage.write('guest_address', _addressText);
      storage.write('guest_lat', _selectedLocation.latitude);
      storage.write('guest_long', _selectedLocation.longitude);
    }
    Get.offAllNamed(AppRoutes.login);
  }

  void _continueToRegister() {
    if (_addressText.isEmpty) return;
    final locationType = _selectedTypeIndex == 0
        ? 'home'
        : _selectedTypeIndex == 1
            ? 'work'
            : 'other';
    final notes = _detailsController.text.trim();
    final storage = GetStorage();
    storage.write(AppConstants.onboardingSeenKey, true);
    storage.write('selected_address', _addressText);
    storage.write('selected_lat', _selectedLocation.latitude);
    storage.write('selected_long', _selectedLocation.longitude);
    storage.write('selected_location_type', locationType);
    if (notes.isNotEmpty) {
      storage.write('selected_location_notes', notes);
    }

    Get.toNamed(
      AppRoutes.register,
      arguments: {
        'address': _addressText,
        'lat': _selectedLocation.latitude,
        'long': _selectedLocation.longitude,
        'locationType': locationType,
        'notes': notes,
      },
    );
  }

  void _goToLogin() {
    final storage = GetStorage();
    storage.write(AppConstants.onboardingSeenKey, true);
    if (_addressText.isNotEmpty) {
      storage.write('selected_address', _addressText);
      storage.write('selected_lat', _selectedLocation.latitude);
      storage.write('selected_long', _selectedLocation.longitude);
    }
    Get.toNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: _defaultZoom,
              ),
              onMapCreated: (c) => _mapController = c,
              onCameraMove: (pos) {
                setState(() {
                  _isMapMoving = true;
                  _selectedLocation = pos.target;
                });
              },
              onCameraIdle: () {
                setState(() => _isMapMoving = false);
                _reverseGeocode(_selectedLocation);
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              polygons: {
                for (final zone in _coverageZones)
                  if (zone.verticesCount >= 3)
                    Polygon(
                      polygonId: PolygonId(zone.name),
                      points: zone.polygonPoints,
                      strokeWidth: 2,
                      strokeColor: _coveragePurple.withOpacity(
                        _activeCoverageZone?.name == zone.name ? 0.95 : 0.45,
                      ),
                      fillColor: _coveragePurple.withOpacity(
                        _activeCoverageZone?.name == zone.name ? 0.24 : 0.08,
                      ),
                    ),
              },
            ),
          ),

          // Center pin marker
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.only(bottom: _isMapMoving ? 16.h : 0),
                  child: SvgPicture.asset(
                    'assets/svg/auth/Icon-8.svg',
                    width: 48.w,
                    height: 48.h,
                  ),
                ),
                if (!_isMapMoving)
                  Container(
                    width: 8.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
              ],
            ),
          ),

          // My location button (top-left)
          Positioned(
            left: 16.w,
            top: MediaQuery.of(context).padding.top + 16.h,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _goToMyLocation,
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svg/auth/Icon.svg',
                        width: 24.w,
                        height: 24.h,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: _openNavigationToSelectedLocation,
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.navigation_rounded,
                      color: AppColors.primary,
                      size: 24.r,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Coverage status badge (top-center)
          Positioned(
            top: MediaQuery.of(context).padding.top + 28.h,
            left: 0,
            right: 0,
            child: Center(
              child: _CoverageBadge(
                isInCoverage: _isInCoverage,
                coverageLabel: _activeCoverageZone?.displayLabel,
              ),
            ),
          ),

          // Draggable bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.42,
            minChildSize: 0.18,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.18, 0.42, 0.88],
            builder: (context, scrollController) {
              return _BottomSheet(
                scrollController: scrollController,
                addressText: _addressText,
                isLoading: _isGeocodingLoading,
                showDetails: _showDetails,
                selectedTypeIndex: _selectedTypeIndex,
                detailsController: _detailsController,
                onToggleDetails: () => setState(() => _showDetails = !_showDetails),
                onTypeSelected: (i) => setState(() => _selectedTypeIndex = i),
                onContinueToRegister: _continueToRegister,
                onContinueAsGuest: _continueAsGuest,
                onGoToLogin: _goToLogin,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CoverageZone {
  final String name;
  final String levelKey;
  final List<LatLng> coordinates;

  const _CoverageZone({
    required this.name,
    required this.levelKey,
    required this.coordinates,
  });

  List<LatLng> get polygonPoints {
    if (coordinates.length < 2) return coordinates;
    final first = coordinates.first;
    final last = coordinates.last;
    final isClosed =
        first.latitude == last.latitude && first.longitude == last.longitude;
    return isClosed ? coordinates.sublist(0, coordinates.length - 1) : coordinates;
  }

  int get verticesCount => polygonPoints.length;

  String get displayLabel {
    switch (levelKey) {
      case 'country':
        return 'دولة $name';
      case 'state':
        return 'ولاية $name';
      default:
        return 'مدينة $name';
    }
  }
}

class _CoverageBadge extends StatelessWidget {
  final bool isInCoverage;
  final String? coverageLabel;

  const _CoverageBadge({
    required this.isInCoverage,
    this.coverageLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isInCoverage
            ? AppColors.successGreen.withOpacity(0.9)
            : AppColors.notificationRed.withOpacity(0.9),
        borderRadius: BorderRadius.circular(100.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/svg/auth/Icon-3.svg',
            width: 20.w,
            height: 20.h,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            isInCoverage
                ? 'داخل نطاق ${coverageLabel ?? 'التغطية'}'
                : 'خارج منطقة التغطية',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final String addressText;
  final bool isLoading;
  final bool showDetails;
  final int selectedTypeIndex;
  final TextEditingController detailsController;
  final VoidCallback onToggleDetails;
  final ValueChanged<int> onTypeSelected;
  final VoidCallback onContinueToRegister;
  final VoidCallback onContinueAsGuest;
  final VoidCallback onGoToLogin;

  const _BottomSheet({
    required this.scrollController,
    required this.addressText,
    required this.isLoading,
    required this.showDetails,
    required this.selectedTypeIndex,
    required this.detailsController,
    required this.onToggleDetails,
    required this.onTypeSelected,
    required this.onContinueToRegister,
    required this.onContinueAsGuest,
    required this.onGoToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 50,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 16.h,
          ),
          child: Column(
            children: [
            SizedBox(height: 24.h),

            // Drag handle
            Container(
              width: 48.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DC),
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),

            SizedBox(height: 24.h),

            // Address card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _AddressCard(
                addressText: addressText,
                isLoading: isLoading,
              ),
            ),

            SizedBox(height: 24.h),

            // "حفظ الموقع كـ" label
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  'حفظ الموقع كـ',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF364153),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Location type buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Expanded(
                    child: _LocationTypeButton(
                      icon: 'assets/svg/auth/Icon-1.svg',
                      label: 'موقع آخر',
                      isSelected: selectedTypeIndex == 2,
                      onTap: () => onTypeSelected(2),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _LocationTypeButton(
                      icon: 'assets/svg/auth/Icon-2.svg',
                      label: 'العمل',
                      isSelected: selectedTypeIndex == 1,
                      onTap: () => onTypeSelected(1),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _LocationTypeButton(
                      icon: 'assets/svg/auth/Icon-5.svg',
                      label: 'المنزل',
                      isSelected: selectedTypeIndex == 0,
                      onTap: () => onTypeSelected(0),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Details section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: AnimatedCrossFade(
                firstChild: _AddDetailsButton(onTap: onToggleDetails),
                secondChild: _DetailsTextArea(controller: detailsController),
                crossFadeState: showDetails
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ),

            SizedBox(height: 16.h),

            // Continue to register button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GestureDetector(
                onTap: onContinueToRegister,
                child: Container(
                  width: double.infinity,
                  height: 68.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6938D3),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFAD46FF).withOpacity(0.25),
                        blurRadius: 25,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Continue as guest button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GestureDetector(
                onTap: onContinueAsGuest,
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFF6938D3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'المتابعة كزائر',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6938D3),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Login link
            TextButton(
              onPressed: onGoToLogin,
              child: Text(
                'لدي حساب بالفعل',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6938D3),
                ),
              ),
            ),

            // Guest info text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'يمكنك تصفح التطبيق بدون خدمة التوصيل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6A7282),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String addressText;
  final bool isLoading;

  const _AddressCard({
    required this.addressText,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'العنوان المحدد',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6A7282),
                  ),
                ),
                SizedBox(height: 4.h),
                isLoading
                    ? SizedBox(
                        height: 16.h,
                        width: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        addressText.isNotEmpty
                            ? addressText
                            : 'جاري تحديد العنوان...',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFF6938D3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/svg/auth/Icon-4.svg',
                width: 24.w,
                height: 24.h,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6938D3),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationTypeButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 87.h,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6938D3).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6938D3)
                : AppColors.borderGray,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? const Color(0xFF6938D3)
                    : const Color(0xFF364153),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF6938D3)
                    : const Color(0xFF364153),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddDetailsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddDetailsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 59.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFD1D5DC),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'إضافة تفاصيل العنوان',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A5565),
              ),
            ),
            SizedBox(width: 8.w),
            SvgPicture.asset(
              'assets/svg/auth/Icon-7.svg',
              width: 20.w,
              height: 20.h,
              colorFilter: const ColorFilter.mode(
                Color(0xFF4A5565),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsTextArea extends StatelessWidget {
  final TextEditingController controller;

  const _DetailsTextArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 107.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFDADAEB),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: 'تفاصيل إضافية (مثل: بناية رقم 5، الطابق الثالث)',
          hintStyle: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textDark.withOpacity(0.5),
          ),
          contentPadding: EdgeInsets.all(16.w),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
