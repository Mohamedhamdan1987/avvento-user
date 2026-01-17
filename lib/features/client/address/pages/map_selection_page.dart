import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:avvento/core/constants/app_colors.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_text_field.dart';
import '../controllers/address_controller.dart';

class MapSelectionPage extends StatefulWidget {
  const MapSelectionPage({super.key});

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(32.8872, 13.1913); // Default Tripoli
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isMoving = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'اختر موقع التوصيل',
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // Map
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 15,
              ),
              onMapCreated: (c) => _mapController = c,
              onCameraMove: (pos) {
                setState(() {
                  _isMoving = true;
                  _selectedLocation = pos.target;
                });
              },
              onCameraIdle: () {
                setState(() => _isMoving = false);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
            // Center Marker
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.only(bottom: _isMoving ? 20.h : 0),
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.purple,
                        size: 48.r,
                      ),
                    ),
                    Container(
                      width: 8.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Form
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل العنوان',
                      style: const TextStyle().textColorBold(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: _labelController,
                      hint: 'اسم العنوان (مثلاً: المنزل، العمل)',
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: 12,
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField(
                      controller: _addressController,
                      hint: 'وصف العنوان (الشارع، رقم المبنى...)',
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: 12,
                      maxLines: 2,
                    ),
                    SizedBox(height: 24.h),
                    Obx(() => CustomButtonApp(
                      text: 'حفظ العنوان',
                      onTap: () {
                        if (_labelController.text.isEmpty || _addressController.text.isEmpty) {
                          Get.snackbar('تنبیه', 'يرجى إكمال جميع الحقول');
                          return;
                        }
                        controller.addAddress(
                          label: _labelController.text,
                          address: _addressController.text,
                          lat: _selectedLocation.latitude,
                          long: _selectedLocation.longitude,
                        );
                      },
                      isLoading: controller.isLoading.value,
                      color: AppColors.purple,
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
