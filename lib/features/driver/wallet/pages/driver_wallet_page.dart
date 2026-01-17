import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../../../../core/widgets/reusable/safe_svg_icon.dart';
import '../widgets/wallet_transaction_item.dart';
import '../widgets/wallet_summary_card.dart';
import '../controllers/driver_wallet_controller.dart';

class DriverWalletPage extends StatefulWidget {
  const DriverWalletPage({super.key});

  @override
  State<DriverWalletPage> createState() => _DriverWalletPageState();
}

class _DriverWalletPageState extends State<DriverWalletPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DriverWalletController controller = Get.put(DriverWalletController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoading.value && controller.wallet.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              // Header Section
              _buildHeaderSection(),

              // Content Section
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refreshWallet(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.h),
                        // Main Balance Card
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                          child: _buildMainBalanceCard(),
                        ),
                        SizedBox(height: 24.h),

                        // Summary Cards
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                          child: _buildSummaryCards(),
                        ),
                        SizedBox(height: 24.h),

                        // Tabs and Content
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tab Bar
                              _buildTabBar(),
                              SizedBox(height: 16.h),

                              // Tab Content
                              SizedBox(
                                height: 400.h,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildTransactionsTab(),
                                    _buildSettlementsTab(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsetsDirectional.only(
        start: 16.w,
        end: 16.w,
        top: 48.h,
        bottom: 12.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'المحفظة المالية',
            style: const TextStyle().textColorBold(
              fontSize: 24.sp,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),

          CustomIconButtonApp(
            width: 36.w,
            height: 36.h,
            radius: 100.r,
            color: Theme.of(context).cardColor,
            onTap: () => controller.refreshWallet(),
            childWidget: controller.isLoading.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : SafeSvgIcon(
                    iconName: 'assets/svg/driver/wallet/redresh_icon.svg',
                    width: 20.w,
                    height: 20.h,
                    color: Theme.of(context).iconTheme.color,
                    fallbackIcon: Icons.refresh,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainBalanceCard() {
    final balance = controller.wallet.value?.balance ?? 0.0;
    return Container(
      height: 176.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF2D2D44),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            end: 0,
            top: -40.h,
            child: Container(
              width: 128.w,
              height: 128.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'صافي الرصيد المستحق لك',
                  style: const TextStyle().textColorMedium(
                    fontSize: 14.sp,
                    color: const Color(0xFF99A1AF),
                  ),
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      balance.toStringAsFixed(2),
                      style: const TextStyle().textColorBold(
                        fontSize: 36.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Text(
                        'د.ل',
                        style: const TextStyle().textColorNormal(
                          fontSize: 18.sp,
                          color: const Color(0xFF99A1AF),
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        text: 'إيداع رصيد',
                        iconName: 'assets/svg/driver/wallet/settlement_icon.svg',
                        fallbackIcon: Icons.add,
                        isPrimary: false,
                        onTap: () {
                          _showDepositDialog();
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildActionButton(
                        text: 'سحب أرباح',
                        iconName: 'assets/svg/driver/wallet/withdraw_icon.svg',
                        fallbackIcon: Icons.arrow_upward,
                        isPrimary: true,
                        onTap: () {
                          // TODO: Implement withdrawal
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog() {
    final amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'إيداع رصيد',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: const InputDecoration(
            hintText: 'أدخل المبلغ',
            suffixText: 'د.ل',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Get.back();
                // We'll reuse the WalletService to deposit
                // Ideally this would be in the controller
                try {
                  await controller.refreshWallet(); // Refresh after (mock) deposit
                  Get.snackbar('نجاح', 'تم إيداع الرصيد بنجاح');
                } catch (e) {
                  Get.snackbar('خطأ', 'فشل في عملية الإيداع');
                }
              }
            },
            child: const Text('إيداع'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required String iconName,
    required IconData fallbackIcon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SafeSvgIcon(
              iconName: iconName,
              width: 16.r,
              height: 16.r,
              color: Colors.white,
              fallbackIcon: fallbackIcon,
            ),
            SizedBox(width: 8.w),
            Text(
              text,
              style: const TextStyle().textColorBold(
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalSpent = controller.wallet.value?.totalSpent ?? 0.0;
    final totalEarned = controller.wallet.value?.totalEarned ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: WalletSummaryCard(
            title: 'أرباحك (الصافي)',
            amount: totalEarned,
            iconColor: const Color(0xFFF0FDF4),
            iconName: 'assets/svg/driver/wallet/income_icon.svg',
            fallbackIcon: Icons.account_balance_wallet,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: WalletSummaryCard(
            title: 'عليك (عهد نقدية)',
            amount: -totalSpent,
            iconColor: const Color(0xFFFFFBEB),
            iconName: 'assets/svg/driver/wallet/debt_icon.svg',
            fallbackIcon: Icons.remove_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48.h,
      width: double.infinity,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: TabBar(
        controller: _tabController,
        tabAlignment: TabAlignment.fill,
        indicator: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        labelColor: Theme.of(context).textTheme.bodyLarge?.color,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        labelStyle: const TextStyle().textColorBold(
          fontSize: 14.sp,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'سجل العمليات'),
          Tab(text: 'التسويات'),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    final transactions = controller.transactions;

    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'لا توجد عمليات حالياً',
          style: const TextStyle().textColorMedium(
            fontSize: 16.sp,
            color: Theme.of(context).hintColor,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: WalletTransactionItem(
            type: transaction.type,
            amount: transaction.amount,
            title: transaction.description.split('\n').first,
            description: '${transaction.createdAt.hour}:${transaction.createdAt.minute} • ${transaction.status}',
            iconName: transaction.type == 'credit' 
                ? 'assets/svg/driver/wallet/income_icon.svg'
                : 'assets/svg/driver/wallet/debt_icon.svg',
            fallbackIcon: transaction.type == 'credit' ? Icons.arrow_upward : Icons.arrow_downward,
          ),
        );
      },
    );
  }

  Widget _buildSettlementsTab() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.76.w,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: SafeSvgIcon(
                iconName: 'assets/svg/driver/wallet/wallet_empty_icon.svg',
                width: 32.r,
                height: 32.r,
                color: Theme.of(context).hintColor,
                fallbackIcon: Icons.account_balance_wallet_outlined,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'لا توجد تسويات معلقة',
              style: const TextStyle().textColorBold(
                fontSize: 18.sp,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'يتم تصفية الحسابات بشكل تلقائي كل يوم أحد',
              style: const TextStyle().textColorNormal(
                fontSize: 14.sp,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}