import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login(String username, String password) async {
    try {
      final loginResponse = await remoteDataSource.login(username, password);
      // Save token and user locally
      await localDataSource.saveToken(loginResponse.token);
      await localDataSource.saveUser(loginResponse.user);
      return loginResponse.user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> register({
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
      final userModel = await remoteDataSource.register(
        name: name,
        username: username,
        email: email,
        phone: phone,
        password: password,
        address: address,
        lat: lat,
        long: long,
      );
      await localDataSource.saveUser(userModel);
      return userModel;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendOtp(String email, String phone, String role) async {
    await remoteDataSource.sendOtp(email, phone, role);
  }

  @override
  Future<void> verifyOtp(String email, String phone, String otpCode) async {
    await remoteDataSource.verifyOtp(email, phone, otpCode);
  }

  @override
  Future<void> forgetPassword(String username) async {
    await remoteDataSource.forgetPassword(username);
  }

  @override
  Future<void> resetPassword(String username, String newPassword, String otpCode) async {
    await remoteDataSource.resetPassword(username, newPassword, otpCode);
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await remoteDataSource.changePassword(currentPassword, newPassword);
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAll();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await localDataSource.getUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }
}

