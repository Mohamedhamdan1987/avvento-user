import 'package:avvento/core/widgets/reusable/app_refresh_indicator.dart';
import 'package:avvento/core/constants/app_colors.dart';
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/features/client/address/controllers/address_controller.dart';
import 'package:avvento/features/client/address/models/address_model.dart';
import 'package:avvento/core/utils/app_dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/shimmer/shimmer_loading.dart';

class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'عناوين التوصيل',
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.addresses.isEmpty) {
                  return const AddressListShimmer();
                }

                if (controller.addresses.isEmpty) {
                  return _buildEmptyState(context);
                }

                return AppRefreshIndicator(
                  onRefresh: controller.fetchAddresses,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 24.h,
                    ),
                    itemCount: controller.addresses.length,
                    itemBuilder: (context, index) {
                      final address = controller.addresses[index];
                      return _buildAddressCard(context, address, controller);
                    },
                  ),
                );
              }),
            ),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/client/location.svg',
            width: 80.w,
            height: 80.h,
            colorFilter: ColorFilter.mode(
              Theme.of(context).disabledColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد عناوين مسجلة',
            style: const TextStyle().textColorBold(
              fontSize: 18,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'قم بإضافة عنوان جديد لتسهيل عملية التوصيل',
            style: const TextStyle().textColorNormal(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    AddressModel address,
    AddressController controller,
  ) {
    // Check if this page was opened for selection (from checkout)
    final isSelectionMode = Get.arguments == true;

    return GestureDetector(
      onTap: isSelectionMode
          ? () {
              // Return selected address
              Get.back(result: address);
            }
          : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: address.isActive
                ? AppColors.purple
                : Theme.of(context).dividerColor,
            width: address.isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon based on label
            Container(
              width: 48.w,
              height: 48.h,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForLabel(address.label),
                color: AppColors.purple,
              ),
            ),
            SizedBox(width: 16.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle().textColorBold(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (address.isActive) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'افتراضي',
                            style: const TextStyle().textColorMedium(
                              fontSize: 10,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    address.address,
                    style: const TextStyle().textColorNormal(
                      fontSize: 13,
                      color: Theme.of(context).hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Actions
            if (!isSelectionMode)
              Row(
                children: [
                  if (!address.isActive)
                    IconButton(
                      onPressed: () => controller.setActive(address.id),
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.textPlaceholder,
                      ),
                    ),
                  IconButton(
                    onPressed: () =>
                        _showDeleteConfirmation(address, controller),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.notificationRed,
                    ),
                  ),
                ],
              )
            else
              // Selection indicator
              Icon(
                Icons.arrow_forward_ios,
                size: 16.r,
                color: AppColors.textPlaceholder,
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    AddressModel address,
    AddressController controller,
  ) {
    AppDialogs.showDeleteConfirmation(
      title: 'حذف العنوان',
      description: 'هل أنت متأكد من حذف عنوان "${address.label}"؟',
      onConfirm: () async {
        await controller.deleteAddress(address.id);
      },
    );
  }

  IconData _getIconForLabel(String label) {
    if (label.contains('منزل') || label.contains('Home')) return Icons.home;
    if (label.contains('عمل') || label.contains('Work')) return Icons.work;
    return CupertinoIcons.building_2_fill;
  }

  Widget _buildAddButton() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: CustomButtonApp(
        text: 'إضافة عنوان جديد',
        onTap: () => Get.toNamed(AppRoutes.mapSelection),
        color: AppColors.purple,
      ),
    );
  }
}
