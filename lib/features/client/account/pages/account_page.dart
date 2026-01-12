import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../favorites/pages/favorites_page.dart';
import '../../../profile/controllers/profile_controller.dart';
import '../../../profile/pages/edit_profile_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize AuthController if it doesn't exist
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    final profileController = Get.put(ProfileController());
    final user = authController.getCachedUser();
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          _buildHeader(profileController, user),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  _buildSettingsList(),
                  SizedBox(height: 100.h), // Spacing for navigation bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ProfileController profileController, dynamic user) {
    return Obx(() {
      final profile = profileController.userProfile.value;
      return Container(
        height: 260.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 10),
              blurRadius: 15,
              spreadRadius: -3,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background with gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.purple.withOpacity(0.8),
                    AppColors.purple,
                    AppColors.purpleDark,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Decorative circles (optional, matching home aesthetic)
            Positioned(
              top: -50.h,
              left: -50.w,
              child: Container(
                width: 150.w,
                height: 150.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Text(
                      'حسابي',
                      style: const TextStyle().textColorBold(
                        fontSize: 18,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        // Profile Image
                        Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: profile?.logo != null
                                ? DecorationImage(
                                    image: NetworkImage(profile!.logo!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: profile?.logo == null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(40.r),
                                  child: Image.network(
                                    'https://ui-avatars.com/api/?name=${profile?.name ?? user?.username ?? "User"}&background=random',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.person, size: 40, color: AppColors.purple),
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: 16.w),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?.name ?? user?.username ?? 'مستخدم',
                                style: const TextStyle().textColorBold(
                                  fontSize: 20,
                                  color: AppColors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                profile?.phone ?? user?.phone ?? '',
                                style: const TextStyle().textColorNormal(
                                  fontSize: 14,
                                  color: AppColors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Edit Button
                        CustomIconButtonApp(
                          onTap: () => Get.to(() => const EditProfilePage()),
                          width: 40.w,
                          height: 40.h,
                          color: AppColors.white.withOpacity(0.2),
                          childWidget: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSettingsList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          _buildSettingsItem(
            iconPath: 'assets/svg/client/location.svg',
            title: 'عناوين التوصيل',
            onTap: () => Get.toNamed(AppRoutes.addressList),
          ),
          _buildSettingsItem(
            iconPath: 'assets/svg/client/home/favorite.svg',
            title: 'المفضلة',
            onTap: () => Get.to(() => const FavoritesPage()),
          ),
          _buildSettingsItem(
            iconPath: 'assets/svg/client/home/notification.svg',
            title: 'التنبيهات',
            onTap: () {
              Get.toNamed(AppRoutes.notifications);
            },
          ),
          _buildSettingsItem(
            iconPath: 'assets/svg/client/home/location_pin.svg', // Placeholder for language or similar
            title: 'اللغة',
            subtitle: 'العربية',
            onTap: () {},
          ),
          _buildSettingsItem(
            iconPath: 'assets/svg/client/home/search.svg', // Placeholder for help
            title: 'الدعم والمساعدة',
            onTap: () {},
          ),
          _buildSettingsItem(
            iconPath: 'assets/svg/client/home/store.svg', // Placeholder for about
            title: 'عن التطبيق',
            onTap: () {},
          ),
          SizedBox(height: 12.h),
          _buildSettingsItem(
            iconPath: 'assets/svg/client/orders/cancel_icon.svg',
            title: 'تسجيل الخروج',
            titleColor: AppColors.notificationRed,
            showChevron: false,
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String iconPath,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    bool showChevron = true,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),

        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          width: 40.w,
          height: 40.h,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(
              titleColor ?? AppColors.purple,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle().textColorMedium(
            fontSize: 15,
            color: titleColor ?? AppColors.textDark,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle().textColorNormal(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              )
            : null,
        trailing: showChevron
            ? Icon(
                Icons.chevron_right,
                color: AppColors.textPlaceholder,
                size: 20.r,
              )
            : null,
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'تسجيل الخروج',
          style: const TextStyle().textColorBold(
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textMedium,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              // Safely get or initialize AuthController
              final authController = Get.isRegistered<AuthController>()
                  ? Get.find<AuthController>()
                  : Get.put(AuthController());
              authController.logout();
            },
            child: Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.notificationRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
