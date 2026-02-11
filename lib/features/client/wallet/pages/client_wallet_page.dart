import 'package:avvento/core/widgets/reusable/app_refresh_indicator.dart';
import 'package:avvento/features/client/wallet/controllers/client_wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../../../../core/widgets/reusable/safe_svg_icon.dart';
import '../../../driver/wallet/widgets/wallet_transaction_item.dart';
import '../../../../core/widgets/shimmer/shimmer_loading.dart';


class ClientWalletPage extends StatelessWidget {
  const ClientWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientWalletController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'محفظتي',
          style: const TextStyle().textColorBold(
            fontSize: 20,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color),
          onPressed: () => Get.back(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoading.value && controller.wallet.value == null) {
            return const WalletPageShimmer();
          }

          return AppRefreshIndicator(
            onRefresh: () => controller.refreshWallet(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _buildBalanceCard(controller),
                  SizedBox(height: 32.h),
                  Text(
                    'العمليات الأخيرة',
                    style: const TextStyle().textColorBold(
                      fontSize: 18,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildTransactionsList(context, controller),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBalanceCard(ClientWalletController controller) {
    final balance = controller.wallet.value?.balance ?? 0.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purple,
            AppColors.purpleDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'رصيدك الحالي',
            style: const TextStyle().textColorMedium(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '${balance.toStringAsFixed(2)} د.ل',
            style: const TextStyle().textColorBold(
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24.h),
          _buildActionButton(
            text: 'إيداع رصيد',
            icon: Icons.add_circle_outline,
            onTap: () => controller.onRechargeWithCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 8.w),
            Text(
              text,
              style: const TextStyle().textColorBold(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, ClientWalletController controller) {
    final transactions = controller.transactions;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: 48.h),
            Icon(Icons.account_balance_wallet_outlined, size: 64.r, color: Theme.of(context).hintColor),
            SizedBox(height: 16.h),
            Text(
              'لا توجد عمليات سابقة',
              style: const TextStyle().textColorMedium(
                fontSize: 16,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: WalletTransactionItem(
            type: transaction.type,
            amount: transaction.amount,
            title: transaction.description,
            description: '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}',
            iconName: transaction.type == 'credit' 
                ? 'assets/svg/driver/wallet/income_icon.svg'
                : 'assets/svg/driver/wallet/debt_icon.svg',
            fallbackIcon: transaction.type == 'credit' ? Icons.arrow_downward : Icons.arrow_upward,
          ),
        );
      },
    );
  }


}
