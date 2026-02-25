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
}
