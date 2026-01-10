import 'package:avvento/core/constants/app_constants.dart';
import 'package:avvento/core/utils/show_snackbar.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:avvento/core/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_text_field.dart';

import 'package:avvento/core/constants/app_colors.dart';

import '../controllers/auth_controller.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;
  final GetStorage storage;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
    required this.storage,
  });

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isLoginLoading = false.obs;
  final RxBool isRegisterLoading = false.obs;
  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final isAuth = await authRepository.isAuthenticated();
    if (isAuth) {
      currentUser.value = await authRepository.getCurrentUser();
    }
  }

  Future<void> login(String username, String password) async {
    // Validate inputs
    if (username.trim().isEmpty) {
      showSnackBar(
        title: 'خطأ',
        message: 'يرجى إدخال اسم المستخدم',
        isError: true,
      );
      return;
    }

    if (password.isEmpty) {
      showSnackBar(
        title: 'خطأ',
        message: 'يرجى إدخال كلمة المرور',
        isError: true,
      );
      return;
    }

    try {
      isLoginLoading.value = true;
      final user = await loginUseCase(username.trim(), password);

      // User and token are already saved in repository
      currentUser.value = user;
      
      showSnackBar(
        title: 'نجح',
        message: 'تم تسجيل الدخول بنجاح',
      );

      // Navigate based on user role
      if (user.role == 'client') {
        Get.offAllNamed(AppRoutes.clientNavBar);
      } else if (user.role == 'delivery' || user.role == 'delivery') {
        // TODO: Add driver route when implemented
        Get.offAllNamed(AppRoutes.login);
      } else {
        // TODO: Add client route when implemented
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      String errorMessage = 'فشل تسجيل الدخول';
      if (e.toString().contains('Invalid credentials') || 
          e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        errorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحة';
      } else if (e.toString().contains('Exception: ')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      
      showSnackBar(
        title: 'خطأ',
        message: errorMessage,
        isError: true,
      );
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
    String? address,
    double? lat,
    double? long,
  }) async {
    try {
      isRegisterLoading.value = true;
      final user = await registerUseCase(
        name: name,
        username: username,
        email: email,
        phone: phone,
        password: password,
        address: address,
        lat: lat,
        long: long,
      );

      currentUser.value = user;
      await storage.write(AppConstants.userKey, user.toJson());
      
      showSnackBar(
        title: 'نجح',
        message: 'تم التسجيل بنجاح',
      );

      Get.offAllNamed(AppRoutes.clientNavBar);
    } catch (e) {
      String errorMessage = 'فشل التسجيل';
      if (e.toString().contains('Exception: ')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      
      showSnackBar(
        title: 'خطأ',
        message: errorMessage,
        isError: true,
      );
    } finally {
      isRegisterLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: e.toString(),
        isError: true,
      );
    }
  }

  Future<void> sendOtp(String email, String phone, String role) async {
    try {
      isLoading.value = true;
      await authRepository.sendOtp(email, phone, role);
      showSnackBar(
        title: 'نجح',
        message: 'تم إرسال رمز التحقق',
      );
    } catch (e) {
      showSnackBar(
        title: 'خطأ',
        message: e.toString(),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    // Validate inputs
    if (currentPassword.isEmpty) {
      showSnackBar(
        title: 'خطأ',
        message: 'يرجى إدخال كلمة المرور الحالية',
        isError: true,
      );
      return;
    }

    if (newPassword.isEmpty) {
      showSnackBar(
        title: 'خطأ',
        message: 'يرجى إدخال كلمة المرور الجديدة',
        isError: true,
      );
      return;
    }

    if (newPassword.length < 6) {
      showSnackBar(
        title: 'خطأ',
        message: 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      await authRepository.changePassword(currentPassword, newPassword);
      showSnackBar(
        title: 'نجح',
        message: 'تم تغيير كلمة المرور بنجاح',
      );
      Get.back(); // Navigate back after successful change
    } catch (e) {
      String errorMessage = 'فشل تغيير كلمة المرور';
      
      // Extract error message from exception
      final errorString = e.toString();
      if (errorString.contains('Exception: ')) {
        errorMessage = errorString.replaceFirst('Exception: ', '').trim();
      } else if (errorString.contains(':')) {
        // Try to extract message after colon
        final parts = errorString.split(':');
        if (parts.length > 1) {
          errorMessage = parts.sublist(1).join(':').trim();
        } else {
          errorMessage = errorString.trim();
        }
      } else {
        errorMessage = errorString.trim();
      }
      
      // If error message is empty or generic, use default
      if (errorMessage.isEmpty || errorMessage == 'Exception' || errorMessage == e.toString()) {
        errorMessage = 'فشل تغيير كلمة المرور. يرجى التحقق من كلمة المرور الحالية والمحاولة مرة أخرى';
      }
      
      showSnackBar(
        title: 'خطأ',
        message: errorMessage,
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

