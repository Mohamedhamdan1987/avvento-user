import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/reusable/custom_app_bar.dart';
import '../../../../core/widgets/reusable/custom_text_field.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_button_app.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        title: 'تعديل الملف الشخصي',
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePickers(controller),
              SizedBox(height: 24.h),
              CustomTextField(
                label: 'الاسم',
                hint: 'أدخل اسمك',
                controller: controller.nameController,
                prefixIcon: Icons.person_outline,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'البريد الإلكتروني',
                hint: 'example@mail.com',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'رقم الهاتف',
                hint: '05xxxxxxxx',
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'العنوان',
                hint: 'أدخل عنوانك',
                controller: controller.addressController,
                prefixIcon: Icons.location_on_outlined,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'اسم المالك',
                hint: 'أدخل اسم المالك',
                controller: controller.ownerNameController,
                prefixIcon: Icons.business_outlined,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'الوصف',
                hint: 'أدخل وصفاً قصيراً',
                controller: controller.descriptionController,
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
              ),
              SizedBox(height: 32.h),
              Obx(() => CustomButtonApp(
                    text: 'حفظ التغييرات',
                    onTap: controller.updateProfile,
                    isLoading: controller.isUpdating.value,
                    color: AppColors.primary,
                  )),
              SizedBox(height: 32.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildImagePickers(ProfileController controller) {
    return Column(
      children: [
        // Background Image Picker
        GestureDetector(
          onTap: () => controller.pickImage(false),
          child: Container(
            width: double.infinity,
            height: 150.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.r),
              image: controller.selectedBackground.value != null
                  ? DecorationImage(
                      image: FileImage(controller.selectedBackground.value!),
                      fit: BoxFit.cover,
                    )
                  : (controller.userProfile.value?.backgroundImage != null
                      ? DecorationImage(
                          image: NetworkImage(controller.userProfile.value!.backgroundImage!),
                          fit: BoxFit.cover,
                        )
                      : null),
            ),
            child: controller.selectedBackground.value == null && 
                   controller.userProfile.value?.backgroundImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 40.r, color: Colors.grey),
                      SizedBox(height: 8.h),
                      Text('إضافة صورة الغلاف', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                    ],
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      margin: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit, color: Colors.white, size: 20.r),
                    ),
                  ),
          ),
        ),
        SizedBox(height: 16.h),
        // Logo Picker
        Center(
          child: GestureDetector(
            onTap: () => controller.pickImage(true),
            child: Stack(
              children: [
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    image: controller.selectedLogo.value != null
                        ? DecorationImage(
                            image: FileImage(controller.selectedLogo.value!),
                            fit: BoxFit.cover,
                          )
                        : (controller.userProfile.value?.logo != null
                            ? DecorationImage(
                                image: NetworkImage(controller.userProfile.value!.logo!),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: controller.selectedLogo.value == null &&
                         controller.userProfile.value?.logo == null
                      ? Icon(Icons.person, size: 50.r, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 16.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
