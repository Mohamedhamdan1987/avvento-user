import 'package:get/get.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../wallet/models/wallet_model.dart';
import '../../../wallet/services/wallet_service.dart';
import '../models/settlement_model.dart';

class DriverWalletController extends GetxController {
  final WalletService _walletService = WalletService();

  final RxBool isLoading = false.obs;
  final RxBool isSyncing = false.obs;
  final RxBool isSettlementsLoading = false.obs;
  final RxBool isSubmittingWithdrawal = false.obs;
  final Rx<WalletModel?> wallet = Rx<WalletModel?>(null);
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  final Rx<SettlementResponse?> settlementResponse = Rx<SettlementResponse?>(null);
  final RxList<SettlementOrder> settlements = <SettlementOrder>[].obs;
  final RxString settlementFilter = 'pending'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
    fetchSettlements();
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

  Future<void> fetchSettlements() async {
    try {
      isSettlementsLoading.value = true;
      final response = await _walletService.getSettlements(
        status: settlementFilter.value.isEmpty ? null : settlementFilter.value,
      );
      settlementResponse.value = response;
      settlements.value = response.orders;
    } catch (e) {
      showSnackBar(message: 'فشل في تحميل التسويات', isError: true);
    } finally {
      isSettlementsLoading.value = false;
    }
  }

  void changeSettlementFilter(String filter) {
    settlementFilter.value = filter;
    fetchSettlements();
  }

  Future<void> syncEarnings() async {
    try {
      isSyncing.value = true;
      await _walletService.syncEarnings();
      await fetchWalletData();
      showSnackBar(message: 'تم تحديث بيانات المحفظة', isSuccess: true);
    } catch (e) {
      showSnackBar(message: 'فشل في مزامنة الأرباح', isError: true);
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> refreshWallet() async {
    await Future.wait([
      fetchWalletData(),
      fetchSettlements(),
    ]);
  }

  Future<bool> submitWithdrawal({
    required double amount,
    required String notes,
  }) async {
    final availableAmount = wallet.value?.balance ?? 0.0;

    if (amount <= 0) {
      showSnackBar(message: 'يرجى إدخال مبلغ صحيح', isError: true);
      return false;
    }

    if (amount > availableAmount) {
      showSnackBar(
        message:
            'المبلغ المطلوب يتجاوز الأرباح المتاحة (${availableAmount.toStringAsFixed(2)} د.ل)',
        isError: true,
      );
      return false;
    }

    if (isSubmittingWithdrawal.value) {
      return false;
    }

    try {
      isSubmittingWithdrawal.value = true;
      await _walletService.requestWithdrawal(amount: amount, notes: notes);
      await refreshWallet();
      showSnackBar(message: 'تم إرسال طلب سحب الأرباح بنجاح', isSuccess: true);
      return true;
    } catch (e) {
      showSnackBar(message: 'تعذر إرسال طلب السحب حالياً', isError: true);
      return false;
    } finally {
      isSubmittingWithdrawal.value = false;
    }
  }
}
