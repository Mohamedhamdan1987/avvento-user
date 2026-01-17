import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_app_bar.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../profile/controllers/profile_controller.dart';
import '../../../profile/pages/edit_profile_page.dart';
import '../../../../core/theme/theme_controller.dart';


class DriverAccountPage extends StatelessWidget {
  const DriverAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize AuthController if it doesn't exist
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    final profileController = Get.put(ProfileController());
    final user = authController.getCachedUser();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'حسابي',
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Obx(() {
              final profile = profileController.userProfile.value;
              return Container(
                width: double.infinity,
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        image: profile?.logo != null
                            ? DecorationImage(
                                image: NetworkImage(profile!.logo!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: profile?.logo == null
                          ? Icon(
                              Icons.person,
                              size: 40.r,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    // Name
                    Text(
                      profile?.name ?? user?.username ?? 'السائق',
                      style: const TextStyle().textColorBold(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Phone
                    Text(
                      profile?.phone ?? user?.phone ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    if (profile?.email != null || user?.email != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        profile?.email ?? user!.email!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    // Driver badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            size: 20.r,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'سائق توصيل',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Menu items
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'تعديل الملف الشخصي',
                    onTap: () {
                      Get.to(() => const EditProfilePage());
                    },
                  ),
                  _buildDivider(context),
                  _buildMenuItem(
                    context,
                    icon: Icons.lock_outline,
                    title: 'تغيير كلمة المرور',
                    onTap: () {
                      Get.toNamed(AppRoutes.changePassword);
                    },
                  ),
                  _buildDivider(context),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'الإشعارات',
                    onTap: () {
                      Get.toNamed(AppRoutes.notifications);
                    },
                  ),
                  _buildDivider(context),
                  GetBuilder<ThemeController>(
                    builder: (controller) {
                      return _buildMenuItem(
                        context,
                        icon: Icons.dark_mode_outlined,
                        title: 'الوضع الليلي',
                        onTap: () {
                          controller.changeTheme(!Get.isDarkMode);
                        },
                        trailing: Switch(
                          value: Get.isDarkMode,
                          onChanged: (value) => controller.changeTheme(value),
                          activeColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  // _buildDivider(context),
                  // _buildMenuItem(
                  //   context,
                  //   icon: Icons.language_outlined,
                  //   title: 'اللغة',
                  //   subtitle: 'العربية',
                  //   onTap: () {
                  //     // TODO: Show language selection
                  //   },
                  // ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Support section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'المساعدة والدعم',
                    onTap: () {
                      Get.toNamed(AppRoutes.restaurantSupport);

                    },
                  ),
                  _buildDivider(context),
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'حول التطبيق',
                    onTap: () {
                      // TODO: Show about dialog
                    },
                  ),
                  _buildDivider(context),
                  _buildMenuItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'سياسة الخصوصية',
                    onTap: () {
                      // TODO: Show privacy policy
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Logout button
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.r),
                child: InkWell(
                  onTap: () {
                    _showLogoutDialog(context, authController);
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 24.r,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).iconTheme.color,
                size: 24.r,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).disabledColor,
                    size: 16.r,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.3),
      indent: 60.w,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'تسجيل الخروج',
          style: const TextStyle().textColorBold(
            fontSize: 18,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          style: TextStyle(
            fontSize: 16.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            child: Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
