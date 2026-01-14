import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_profile_model.dart';

class ProfileService {
  final DioClient _dioClient = DioClient.instance;

  Future<UserProfileModel> getProfile() async {
    try {
      final response = await _dioClient.get('wallet/profile');
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      final response = await _dioClient.patch(
        'wallet/profile',
        data: formData,
      );
      return UserProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dioClient.post(
        'wallet/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
