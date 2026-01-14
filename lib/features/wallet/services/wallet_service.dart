import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/wallet_model.dart';

class WalletService {
  final DioClient _dioClient = DioClient.instance;

  Future<WalletModel> getWallet() async {
    try {
      final response = await _dioClient.get('wallet');
      return WalletModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deposit({
    required double amount,
    required String description,
  }) async {
    try {
      final response = await _dioClient.post(
        'wallet/deposit',
        data: {
          'amount': amount,
          'description': description,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionModel>> getTransactions({
    String? type,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        if (type != null) 'type': type,
        'page': page,
        'limit': limit,
      };
      
      final response = await _dioClient.get(
        'wallet/transactions',
        queryParameters: queryParams,
      );
      
      final List transactions = response.data['transactions'] ?? [];
      return transactions.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLogs() async {
    try {
      final response = await _dioClient.get('wallet/logs');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
