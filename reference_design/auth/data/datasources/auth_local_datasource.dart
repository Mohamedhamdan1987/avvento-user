import 'package:avvento/core/constants/app_constants.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final GetStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveToken(String token) async {
    await storage.write(AppConstants.tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return storage.read<String>(AppConstants.tokenKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await storage.write(AppConstants.userKey, user.toJson());
  }

  @override
  Future<UserModel?> getUser() async {
    final userData = storage.read<Map<String, dynamic>>(AppConstants.userKey);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  @override
  Future<void> clearAll() async {
    await storage.remove(AppConstants.tokenKey);
    await storage.remove(AppConstants.userKey);
  }
}

