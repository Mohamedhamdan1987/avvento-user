import 'package:get/get.dart';
import '../../../wallet/models/wallet_model.dart';
import '../../../wallet/services/wallet_service.dart';


class DriverWalletController extends GetxController {
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
}
