import '../../../core/constants/app_constants.dart';
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
  Future<InitPaymentResponse> initiateDepositPayment({
    required double amount,
    required String phone,
    required String email,
  }) async {
    try {
      final response = await _dioClient.post(
        'wallet/deposit/initiate',
        data: {
          "amount": amount,
          "phone": phone,
          "email": email,
          "backendUrl": "${AppConstants.baseUrl}payment/webhook",
          "frontendUrl": "${AppConstants.baseUrl}wallet/deposit/success",
        },
      );
      return InitPaymentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

class InitPaymentResponse {
  final bool success;
  final String paymentUrl;
  final String customRef;

  InitPaymentResponse({
    required this.success,
    required this.paymentUrl,
    required this.customRef,
  });

  factory InitPaymentResponse.fromJson(Map<String, dynamic> json) {
    return InitPaymentResponse(
      success: json['success'] ?? false,
      paymentUrl: json['paymentUrl'] ?? '',
      customRef: json['customRef'] ?? '',
    );
  }
}
