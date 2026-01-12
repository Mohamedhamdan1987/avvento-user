import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/otp_request_model.dart';
import '../models/otp_response_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/reset_password_request_model.dart';

class LoginResult {
  final LoginResponseModel? data;
  final String? errorMessage;
  final String? errorCode;
  final Map<String, dynamic>? errorData;

  LoginResult.success(this.data)
      : errorMessage = null,
        errorCode = null,
        errorData = null;
  LoginResult.failure(this.errorMessage, {this.errorCode, this.errorData})
      : data = null;

  bool get isSuccess => data != null;
}

class AuthService {
  final DioClient _dioClient = DioClient.instance;

  Future<LoginResult> login(LoginRequestModel request) async {
    try {
      // Use validateStatus to accept 401 and 403 as normal response (not exception)
      // 403 is returned when phone is not verified
      final response = await _dioClient.post(
        '/auth/login',
        data: request.toJson(),
        options: Options(
          validateStatus: (status) {
            // Accept 200-299, 401, and 403 as valid responses
            return status != null && (status >= 200 && status < 300 || status == 401 || status == 403);
          },
        ),
      );

      // Parse the response
      final responseData = response.data as Map<String, dynamic>;
      
      // Check if login was successful (either success=true or presence of token/user)
      if (responseData['success'] == true || responseData.containsKey('token')) {
        return LoginResult.success(
          LoginResponseModel.fromJson(responseData),
        );
      } else {
        // Extract error data from response
        final errorData = responseData['data'] as Map<String, dynamic>?;
        final errorCode = responseData['error'] as String? ?? responseData['code'] as String?;
        
        // Return error message from API with error data
        return LoginResult.failure(
          responseData['message'] as String? ?? 'فشل تسجيل الدخول',
          errorCode: errorCode,
          errorData: errorData,
        );
      }
    } on DioException {
      // Only throw for actual network/connection errors
      // 401 is handled above as normal response
      rethrow;
    }
  }

  Future<LoginResult> register(RegisterRequestModel request) async {
    try {
      // Use validateStatus to accept 201, 200-299 and 400 as normal response (not exception)
      final response = await _dioClient.post(
        '/api/auth/register',
        data: request.toJson(),
        options: Options(
          validateStatus: (status) {
            // Accept 200-299 and 400 as valid responses
            return status != null && (status >= 200 && status < 300 || status == 400);
          },
        ),
      );

      // Parse the response
      final responseData = response.data as Map<String, dynamic>;
      
      // Check if registration was successful
      if (responseData['success'] == true || responseData.containsKey('user')) {
        // Check if OTP was sent (user needs verification)
        final otpSent = responseData['otpSent'] as bool? ?? false;
        final userData = responseData['user'] as Map<String, dynamic>?;
        
        if (otpSent || (userData?['isVerified'] as bool? ?? userData?['is_phone_verified'] as bool? ?? false) == false) {
          return LoginResult.success(
            LoginResponseModel.fromJson(responseData),
          );
        } else {
          // User is already verified
          return LoginResult.success(
            LoginResponseModel.fromJson(responseData),
          );
        }
      } else {
        // Return error message from API
        return LoginResult.failure(
          responseData['message'] as String? ?? 'فشل إنشاء الحساب',
        );
      }
    } on DioException {
      // Only throw for actual network/connection errors
      // 400 is handled above as normal response
      rethrow;
    }
  }

  Future<OtpResult> verifyOtp(OtpRequestModel request) async {
    try {
      final response = await _dioClient.post(
        '/api/auth/otp/verify',
        data: request.toJson(),
      );

      // Parse the response
      final responseData = response.data as Map<String, dynamic>;
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      // Check if verification was successful
      if (apiResponse.success && apiResponse.data != null) {
        return OtpResult.success(
          OtpResponseModel.fromJson(apiResponse.data!),
        );
      } else {
        // Return error message from API
        return OtpResult.failure(
          apiResponse.message ?? 'فشل التحقق من رمز OTP',
        );
      }
    } on DioException {
      // Only throw for actual network/connection errors
      rethrow;
    }
  }

  Future<ApiResult> forgotPassword(ForgotPasswordRequestModel request) async {
    try {
      final response = await _dioClient.post(
        '/api/auth/forgot-password',
        data: request.toJson(),
      );

      // Parse the response
      final responseData = response.data as Map<String, dynamic>;
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      // Check if request was successful
      if (apiResponse.success) {
        return ApiResult.success(apiResponse.message ?? 'تم إرسال رمز التحقق بنجاح');
      } else {
        return ApiResult.failure(
          apiResponse.message ?? 'فشل إرسال رمز التحقق',
        );
      }
    } on DioException {
      rethrow;
    }
  }

  Future<ApiResult> resetPassword(ResetPasswordRequestModel request) async {
    try {
      final response = await _dioClient.post(
        '/api/auth/reset-password',
        data: request.toJson(),
        options: Options(
          validateStatus: (status) {
            // Accept 200-299 and 400 as valid responses
            return status != null && (status >= 200 && status < 300 || status == 400);
          },
        ),
      );

      // Parse the response
      final responseData = response.data as Map<String, dynamic>;
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      // Check if reset was successful
      if (apiResponse.success) {
        return ApiResult.success(apiResponse.message ?? 'تم إعادة تعيين كلمة المرور بنجاح');
      } else {
        // Extract remaining attempts if available
        final remainingAttempts = responseData['remainingAttempts'] as int?;
        String errorMessage = apiResponse.message ?? 'فشل إعادة تعيين كلمة المرور';
        if (remainingAttempts != null) {
          errorMessage += ' (محاولات متبقية: $remainingAttempts)';
        }
        return ApiResult.failure(errorMessage, data: {'remainingAttempts': remainingAttempts});
      }
    } on DioException {
      rethrow;
    }
  }
}

class ApiResult {
  final String? message;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  ApiResult.success(this.message) : errorMessage = null, data = null;
  ApiResult.failure(this.errorMessage, {this.data}) : message = null;

  bool get isSuccess => message != null;
}

class OtpResult {
  final OtpResponseModel? data;
  final String? errorMessage;

  OtpResult.success(this.data) : errorMessage = null;
  OtpResult.failure(this.errorMessage) : data = null;

  bool get isSuccess => data != null;
}

