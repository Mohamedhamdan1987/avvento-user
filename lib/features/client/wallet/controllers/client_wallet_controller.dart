import 'package:avvento/core/widgets/webview/SmartWebView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/app_constants.dart';

import '../../../wallet/models/wallet_model.dart';
import '../../../wallet/services/wallet_service.dart';
import '../../../wallet/widgets/enter_amount_dialog.dart';


class ClientWalletController extends GetxController {
  final WalletService _walletService = WalletService();

  final RxBool isLoading = false.obs;
  final Rx<WalletModel?> wallet = Rx<WalletModel?>(null);
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
  }

  Future<void> fetchWalletData() async {
    try {
      isLoading.value = true;
      final walletData = await _walletService.getWallet();
      wallet.value = walletData;
      transactions.value = walletData.transactions;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل بيانات المحفظة');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshWallet() async {
    await fetchWalletData();
  }

  Future<void> deposit(double amount) async {
    try {
      isLoading.value = true;
      await _walletService.deposit(amount: amount, description: 'إيداع رصيد من قبل العميل');
      await fetchWalletData();
      Get.snackbar('نجاح', 'تم إيداع الرصيد بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في إيداع الرصيد');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initiatePaynetlyTopUp({
    required double amount,
    required String phone,
  }) async {
    // isLoading.value = true; // Avoid full screen loading to keep dialog context if needed, or use overlay
    // Better to show loading in the button or a sterile loading dialog if needed.
    // But here we just navigate to WebView.
    
    try {
      // if (!phone.startsWith('+')) {
      //    // Assuming Libyan numbers for now or generic format
      //    // Reference code added +218 if missing.
      //    // If phone starts with 0, replace with +218?
      //    // The reference code: if (!phone.startsWith('+')) phone = '+218$phone';
      //    // Let's blindly follow reference logic or make it smarter.
      //    // If it starts with 09, it adds +21809... which might be wrong double prefix if not careful.
      //    // Standard format: +2189XXXXXXXX.
      //    // If input is 091..., +218091... is usually acceptable by some gateways but incorrect standard.
      //    // Let's assume the user enters local number.
      //    // Reference: phone = '+218$phone';
      //    phone = '+218$phone';
      // }

      final response = await _walletService.initiatePaynetlyPayment(
        amount: amount,
        phone: phone,
        frontendUrl: 'https://yoursite.com/payment-success',
      );

      // Open SmartWebView
      final result = await Get.to(() => SmartWebView(
        url: response.paymentUrl,
         appBar: AppBar(
          title: const Text('طرق الدفع والسداد'),
          backgroundColor: const Color(0xFFF7F7F7),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
              ),
              onPressed: () => Get.back(),
            )
          ],
          leading: Container(),
        ),
        closeWhenUrlContains: 'payment-success',
        onClose: () {
           Get.snackbar('نجاح', 'تمت عملية الدفع بنجاح');
           refreshWallet();
        },
      ));

      if (result != null) {
        refreshWallet();
      }

    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء بدء الدفع: $e');
    } finally {
      // isLoading.value = false;
    }
  }

  void onRechargeWithCard() {
    Get.dialog(
      EnterAmountDialog(
        onConfirm: (amount) async {
           // Get phone logic
           String phone = '0910000000'; // Default fallback
           
           // Try to get from storage directly as we don't have AuthController imported yet/surely
           // Or import AuthController.
           try {
              final storage = GetStorage();
              final userData = storage.read<Map<String, dynamic>>(AppConstants.userKey);
              if (userData != null) {
                 final userPhone = userData['phone'] as String?;
                 if (userPhone != null) phone = userPhone;
              }
           } catch (e) {
             print('Error getting phone: $e');
           }

           await initiatePaynetlyTopUp(
             amount: amount,
             phone: phone,
           );
        },
      ),
    );
  }

}
