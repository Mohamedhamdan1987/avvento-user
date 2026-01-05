import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/address_model.dart';

class AddressService {
  final DioClient _dioClient = DioClient();

  /// Fetch all addresses for the current user
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _dioClient.get('/addresses');
      final List<dynamic> responseData = response.data;
      return responseData.map((item) => AddressModel.fromJson(item)).toList();
    } on DioException {
      rethrow;
    }
  }

  /// Add a new address
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final response = await _dioClient.post(
        '/addresses',
        data: address.toJson(),
      );
      return AddressModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Update an existing address
  Future<AddressModel> updateAddress(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.patch(
        '/addresses/$id',
        data: data,
      );
      return AddressModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Set an address as active
  Future<AddressModel> setActiveAddress(String id) async {
    try {
      final response = await _dioClient.patch('/addresses/$id/active');
      return AddressModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Delete an address
  Future<void> deleteAddress(String id) async {
    try {
      await _dioClient.delete('/addresses/$id');
    } on DioException {
      rethrow;
    }
  }
}
