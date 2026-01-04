import 'package:avvento/core/error/api_exception.dart';
import 'package:avvento/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';

class LoginResponse {
  final UserModel user;
  final String token;

  LoginResponse({required this.user, required this.token});
}

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(String username, String password);
  Future<UserModel> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
    String? address,
    double? lat,
    double? long,
  });
  Future<void> sendOtp(String email, String phone, String role);
  Future<void> verifyOtp(String email, String phone, String otpCode);
  Future<void> forgetPassword(String username);
  Future<void> resetPassword(String username, String newPassword, String otpCode);
  Future<void> changePassword(String currentPassword, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await dioClient.post(
        'auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      final responseData = response.data;
      // Handle different response formats
      if (responseData is Map<String, dynamic>) {
        UserModel userModel;
        if (responseData['user'] != null) {
          userModel = UserModel.fromJson(responseData['user']);
        } else if (responseData['data'] != null && responseData['data']['user'] != null) {
          userModel = UserModel.fromJson(responseData['data']['user']);
        } else {
          userModel = UserModel.fromJson(responseData);
        }
        
        // Extract token from response
        if (responseData['token'] == null || responseData['token'] is! String) {
          throw Exception('Token not found in response');
        }
        final token = responseData['token'] as String;
        
        return LoginResponse(user: userModel, token: token);
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      // Handle DioException and extract error message
      final failure = ApiException.handleException(e);
      throw Exception(failure.message);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register({
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
      final response = await dioClient.post(
        'auth/register-user',
        data: {
          'name': name,
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
          if (address != null) 'address': address,
          if (lat != null) 'lat': lat,
          if (long != null) 'long': long,
        },
      );
      final responseData = response.data;
      // Handle different response formats
      if (responseData is Map<String, dynamic>) {
        if (responseData['user'] != null) {
          return UserModel.fromJson(responseData['user']);
        } else if (responseData['data'] != null && responseData['data']['user'] != null) {
          return UserModel.fromJson(responseData['data']['user']);
        } else {
          return UserModel.fromJson(responseData);
        }
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      // Handle DioException and extract error message
      final failure = ApiException.handleException(e);
      throw Exception(failure.message);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendOtp(String email, String phone, String role) async {
    try {
      await dioClient.post(
        'auth/send-otp',
        data: {
          'email': email,
          'phone': phone,
          'role': role,
        },
      );
    } catch (e) {
      throw Exception('Send OTP failed: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyOtp(String email, String phone, String otpCode) async {
    // OTP verification is typically handled during registration
    // This can be implemented if needed separately
    throw UnimplementedError();
  }

  @override
  Future<void> forgetPassword(String username) async {
    try {
      await dioClient.post(
        'auth/forget-password',
        data: {
          'username': username,
        },
      );
    } catch (e) {
      throw Exception('Forget password failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String username, String newPassword, String otpCode) async {
    try {
      await dioClient.post(
        'auth/reset-password',
        data: {
          'username': username,
          'newPassword': newPassword,
          'otpCode': otpCode,
        },
      );
    } catch (e) {
      throw Exception('Reset password failed: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await dioClient.post(
        'auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      // Extract error message from response
      String errorMessage = 'فشل تغيير كلمة المرور';
      
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] as String? ?? 
                        data['error'] as String? ?? 
                        errorMessage;
        } else if (data is String) {
          errorMessage = data;
        }
      }
      
      // If no message found, use ApiException to get default message
      if (errorMessage == 'فشل تغيير كلمة المرور') {
        final failure = ApiException.handleException(e);
        errorMessage = failure.message;
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      // If it's already an Exception with message, rethrow it
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Change password failed: ${e.toString()}');
    }
  }
}

