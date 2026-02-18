import 'package:avvento/core/widgets/webview/SmartWebView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/show_snackbar.dart';
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
      showSnackBar(message: 'فشل في تحميل بيانات المحفظة', isError: true);
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
      showSnackBar(message: 'تم إيداع الرصيد بنجاح', isSuccess: true);
    } catch (e) {
      showSnackBar(message: 'فشل في إيداع الرصيد', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initiateDepositPayment({
    required double amount,
    required String phone,
    required String email,
  }) async {
    try {
      final response = await _walletService.initiateDepositPayment(
        amount: amount,
        phone: phone,
        email: email,
      );

      final result = await Get.to(() => SmartWebView(
        url: response.paymentUrl,
        appBar: AppBar(
          title: const Text('إيداع رصيد'),
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
        closeWhenUrlContains: 'deposit/success',
        onClose: () {
          showSnackBar(message: 'تم إيداع الرصيد بنجاح', isSuccess: true);
          refreshWallet();
        },
      ));

      if (result != null) {
        refreshWallet();
      }
    } catch (e) {
      showSnackBar(message: 'حدث خطأ أثناء بدء عملية الإيداع', isError: true);
    }
  }

  void onRechargeWithCard() {
    Get.dialog(
      EnterAmountDialog(
        onConfirm: (amount) async {
          String phone = '0910000000';
          String email = 'customer@example.com';

          try {
            final storage = GetStorage();
            final userData = storage.read<Map<String, dynamic>>(AppConstants.userKey);
            if (userData != null) {
              final userPhone = userData['phone'] as String?;
              final userEmail = userData['email'] as String?;
              if (userPhone != null) phone = userPhone;
              if (userEmail != null) email = userEmail;
            }
          } catch (e) {
            print('Error getting user data: $e');
          }

          await initiateDepositPayment(
            amount: amount,
            phone: phone,
            email: email,
          );
        },
      ),
    );
  }

}
