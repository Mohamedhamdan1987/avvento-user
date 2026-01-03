import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String username, String password);
  Future<UserEntity> register({
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
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isAuthenticated();
}

