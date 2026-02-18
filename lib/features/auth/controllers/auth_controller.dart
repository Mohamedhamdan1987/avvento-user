import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/api_exception.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/show_snackbar.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';
import '../models/otp_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;
  final AuthService _authService = AuthService();
  final GetStorage _storage = GetStorage();

  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;

  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  // Get cached token
  String? getToken() {
    return _storage.read<String>(AppConstants.tokenKey);
  }

  // Get cached user data
  UserModel? getCachedUser() {
    final userData = _storage.read<Map<String, dynamic>>(AppConstants.userKey);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getToken() != null && getCachedUser() != null;
  }

  Future<void> login(String username, String password) async {
    _isLoading.value = true;
    try {
      // Create login request
      final request = LoginRequestModel(username: username, password: password);

      // Call the API
      final result = await _authService.login(request);

      // Check if login was successful
      if (result.isSuccess && result.data != null && result.data!.token != null) {
        // Save token to cache
        await _storage.write(AppConstants.tokenKey, result.data!.token!);

        // Save user data to cache
        await _storage.write(AppConstants.userKey, result.data!.user.toJson());

        print("Cached User: ${result.data!.user.toJson()}");

        // Navigate based on user type
        if (result.data!.user.role == 'delivery') {
          Get.offAllNamed(AppRoutes.driverNavBar);
        } else {
          Get.offAllNamed(AppRoutes.clientNavBar);
        }
        showSnackBar(title: 'نجح', message: 'تم تسجيل الدخول بنجاح', isSuccess: true);
      } else {
        // Check if error is PHONE_NOT_VERIFIED
        if (result.errorCode == 'PHONE_NOT_VERIFIED' ||
            result.errorMessage?.contains('يجب التحقق من رقم الهاتف') == true) {
          // Extract phone from error data or use username
          final phone = result.errorData?['phone'] as String? ?? username;
          // Navigate to OTP page
          Get.toNamed(
            AppRoutes.otpVerification,
            arguments: {'phone': phone, 'isFromRegister': false},
          );
        } else {
          // Login failed - show error message from API
          showSnackBar(
            title: 'خطأ',
            message: result.errorMessage ?? 'فشل تسجيل الدخول',
            isError: true,
          );
        }
      }
    } on DioException catch (e) {
      // Handle DioException - check if it's a 401 or 403 with phone verification error
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          final error = responseData['error'] as String?;
          final data = responseData['data'] as Map<String, dynamic>?;
          if (error == 'PHONE_NOT_VERIFIED' && data != null) {
            final phone = data['phone'] as String?;
            if (phone != null) {
              Get.toNamed(
                AppRoutes.otpVerification,
                arguments: {'phone': phone, 'isFromRegister': false},
              );
              return;
            }
          }
        }
      }
      // Handle network/connection errors only
      final failure = ApiException.handleException(e);
      ErrorHandler.handleError(failure);
    } catch (e) {
      // Handle other errors
      showSnackBar(title: 'خطأ', message: 'حدث خطأ غير متوقع: ${e.toString()}', isError: true);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading.value = true;
    try {
      final request = RegisterRequestModel(
        username: username,
        name: name,
        phone: phone,
        email: email,
        password: password,
      );

      // Call the API
      final result = await _authService.register(request);

      // Check if registration was successful
      if (result.isSuccess && result.data != null) {
        // Check if user needs OTP verification (no token or phone not verified)
        final user = result.data!.user;
        final token = result.data!.token;
        
        if (token == null || user.isPhoneVerified == false) {
          // Navigate to OTP verification page
          Get.toNamed(
            AppRoutes.otpVerification,
            arguments: {'phone': phone, 'isFromRegister': true},
          );
        } else {
          // Save token to cache
          await _storage.write(AppConstants.tokenKey, token);

          // Save user data to cache
          await _storage.write(AppConstants.userKey, user.toJson());

          // Navigate based on user type
          if (user.role == 'delivery') {
            Get.offAllNamed(AppRoutes.driverNavBar);
          } else {
            Get.offAllNamed(AppRoutes.clientNavBar);
          }
          showSnackBar(title: 'نجح', message: 'تم إنشاء الحساب بنجاح', isSuccess: true);
        }
      } else {
        // Registration might have succeeded but returned error due to phone verification
        // Check if OTP was sent
        // For now, navigate to OTP page if registration response indicates OTP was sent
        Get.toNamed(
          AppRoutes.otpVerification,
          arguments: {'phone': phone, 'isFromRegister': true},
        );
      }
    } on DioException catch (e) {
      // Handle DioException - check if registration succeeded but needs OTP
      if (e.response?.statusCode == 201 || e.response?.statusCode == 200) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          final apiResponse = responseData;
          if (apiResponse['success'] == true) {
            final data = apiResponse['data'] as Map<String, dynamic>?;
            if (data != null) {
              final user = data['user'] as Map<String, dynamic>?;
              final phoneFromResponse = data['phone'] as String? ?? phone;
              if (user?['is_phone_verified'] == false || data['otpSent'] == true) {
                // Navigate to OTP verification page
                Get.toNamed(
                  AppRoutes.otpVerification,
                  arguments: {'phone': phoneFromResponse, 'isFromRegister': true},
                );
                return;
              }
            }
          }
        }
      }
      // Handle network/connection errors only
      final failure = ApiException.handleException(e);
      ErrorHandler.handleError(failure);
    } catch (e) {
      // Handle other errors
      showSnackBar(title: 'خطأ', message: 'حدث خطأ غير متوقع: ${e.toString()}', isError: true);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    _isLoading.value = true;
    try {
      // Create OTP request
      final request = OtpRequestModel(phone: phone, otp: otp);

      // Call the API
      final result = await _authService.verifyOtp(request);

      // Check if verification was successful
      if (result.isSuccess && result.data != null) {
        // Save token to cache
        await _storage.write(AppConstants.tokenKey, result.data!.token);

        // Save user data to cache
        await _storage.write(AppConstants.userKey, result.data!.user.toJson());

        // Navigate based on user type
        if (result.data!.user.role == 'delivery') {
          Get.offAllNamed(AppRoutes.driverNavBar);
        } else {
          Get.offAllNamed(AppRoutes.clientNavBar);
        }
        showSnackBar(title: 'نجح', message: 'تم التحقق من رقم الهاتف بنجاح', isSuccess: true);
      } else {
        // Verification failed - show error message from API
        showSnackBar(
          title: 'خطأ',
          message: result.errorMessage ?? 'فشل التحقق من رمز OTP',
          isError: true,
        );
      }
    } on DioException catch (e) {
      // Handle network/connection errors only
      final failure = ApiException.handleException(e);
      ErrorHandler.handleError(failure);
    } catch (e) {
      // Handle other errors
      showSnackBar(title: 'خطأ', message: 'حدث خطأ غير متوقع: ${e.toString()}', isError: true);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> forgetPassword(String userName) async {
    _isLoading.value = true;
    try {
      final request = ForgotPasswordRequestModel(userName: userName);
      final result = await _authService.forgotPassword(request);

      if (result.isSuccess) {
        // Navigate to reset password page with OTP verification
        Get.toNamed(
          AppRoutes.resetPassword,
          arguments: {
            "userName": userName,
            "language": "ar"
          },
        );
        showSnackBar(
          title: 'نجح',
          message: result.message ?? 'تم إرسال رمز التحقق بنجاح',
          isSuccess: true,
        );
      } else {
        showSnackBar(
          title: 'خطأ',
          message: result.errorMessage ?? 'فشل إرسال رمز التحقق',
          isError: true,
        );
      }
    } on DioException catch (e) {
      final failure = ApiException.handleException(e);
      ErrorHandler.handleError(failure);
    } catch (e) {
      showSnackBar(title: 'خطأ', message: 'حدث خطأ غير متوقع: ${e.toString()}', isError: true);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> resetPassword(String username, String otp, String newPassword) async {
    _isLoading.value = true;
    try {
      final request = ResetPasswordRequestModel(
        username: username,
        otp: otp,
        newPassword: newPassword,
      );
      final result = await _authService.resetPassword(request);

      if (result.isSuccess) {
        // Navigate to login page
        Get.offAllNamed(AppRoutes.login);
        showSnackBar(
          title: 'نجح',
          message: result.message ?? 'تم إعادة تعيين كلمة المرور بنجاح',
          isSuccess: true,
        );
      } else {
        showSnackBar(
          title: 'خطأ',
          message: result.errorMessage ?? 'فشل إعادة تعيين كلمة المرور',
          isError: true,
        );
      }
    } on DioException catch (e) {
      final failure = ApiException.handleException(e);
      ErrorHandler.handleError(failure);
    } catch (e) {
      showSnackBar(title: 'خطأ', message: 'حدث خطأ غير متوقع: ${e.toString()}', isError: true);
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout and clear all cached data
  Future<void> logout() async {
    try {
      // Clear all authentication data from cache
      await _storage.remove(AppConstants.tokenKey);
      await _storage.remove(AppConstants.userKey);

      // Navigate to login page and clear navigation stack first
      // This ensures we're on a safe page before deleting controllers
      Get.offAllNamed(AppRoutes.login);

      // Clear all GetX controllers after navigation
      // Use a small delay to ensure navigation completes
      await Future.delayed(const Duration(milliseconds: 100));
      Get.deleteAll(force: true);
    } catch (e) {
      showSnackBar(title: 'خطأ', message: 'حدث خطأ أثناء تسجيل الخروج', isError: true);
    }
  }
}
