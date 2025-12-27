import '../../../../core/network/dio_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/user_type.dart';
import '../models/user_model.dart';

class AuthRepo {
  final DioClient dioClient;

  AuthRepo(this.dioClient);

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: 'فشل تسجيل الدخول');
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required UserType userType,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'user_type': userType == UserType.driver ? 'driver' : 'client',
        },
      );

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: 'فشل التسجيل');
    }
  }

  Future<void> logout() async {
    try {
      await dioClient.post('/auth/logout');
    } catch (e) {
      // Ignore logout errors
    }
  }
}

