import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/address_model.dart';

class AddressService {
  final DioClient _dioClient = DioClient.instance;

  /// Fetch all addresses for the current user
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _dioClient.get('/addresses');
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else {
        list = [];
      }
      return list.map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
    } on DioException {
      rethrow;
    }
  }

  /// Add a new address
  Future<AddressModel> addAddress(AddressModel address) async {
    final response = await _dioClient.post(
      '/addresses',
      data: address.toJson(),
    );
    final data = response.data;
    if (data == null) throw FormatException('Empty address response');
    final Map<String, dynamic> map = data is Map
        ? Map<String, dynamic>.from(data)
        : throw FormatException('Invalid address response');
    // Handle wrapped response: { data: {...} } or { address: {...} }
    final inner = map['data'] ?? map['address'];
    final Map<String, dynamic> addressMap = inner is Map
        ? Map<String, dynamic>.from(inner)
        : map;
    return AddressModel.fromJson(addressMap);
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

  /// Set an address as active. Does not throw on unexpected response shape.
  Future<void> setActiveAddress(String id) async {
    await _dioClient.patch('/addresses/$id/active');
    // API may return 200 with body like { success: true } or the address object;
    // we don't need to parse it, fetchAddresses() will refresh the list.
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
