import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../services/profile_service.dart';

class ChangePasswordController extends GetxController {
  final ProfileService _profileService = ProfileService();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final showCurrentPassword = false.obs;
  final showNewPassword = false.obs;
  final showConfirmPassword = false.obs;

  void toggleCurrentPassword() => showCurrentPassword.value = !showCurrentPassword.value;
  void toggleNewPassword() => showNewPassword.value = !showNewPassword.value;
  void toggleConfirmPassword() => showConfirmPassword.value = !showConfirmPassword.value;

  Future<void> changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      showSnackBar(
        title: 'خطأ',
        message: 'كلمة المرور الجديدة غير متطابقة',
        isError: true,
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      showSnackBar(
        title: 'خطأ',
        message: 'كلمة المرور يجب أن لا تقل عن 6 أحرف',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _profileService.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
      
      Get.back();
      showSnackBar(
        title: 'نجاح',
        message: 'تم تغيير كلمة المرور بنجاح',
        isSuccess: true,
      );
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: 'فشل تغيير كلمة المرور. يرجى التأكد من كلمة المرور الحالية.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
