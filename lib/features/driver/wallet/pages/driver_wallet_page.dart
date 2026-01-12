import 'package:avvento/core/widgets/reusable/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import '../../../../core/widgets/reusable/safe_svg_icon.dart';
import '../widgets/wallet_transaction_item.dart';
import '../widgets/wallet_summary_card.dart';

class DriverWalletPage extends StatefulWidget {
  const DriverWalletPage({super.key});

  @override
  State<DriverWalletPage> createState() => _DriverWalletPageState();
}

class _DriverWalletPageState extends State<DriverWalletPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
      backgroundColor: AppColors.lightBackground,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
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
                            height: 300.h,
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
          ],
        ),
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
      // color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title "المحفظة المالية" on the right (in RTL, right = start)
          Text(
            'المحفظة المالية',
            style: const TextStyle().textColorBold(
              fontSize: 24.sp,
              color: AppColors.textDark,
            ),
          ),

          // Back button on the left (in RTL, left = end)
          CustomIconButtonApp(
            width: 36.w,
            height: 36.h,
            radius: 100.r,
            color: Colors.white,
            onTap: () {

            },
            childWidget: SafeSvgIcon(
              iconName: 'assets/svg/driver/wallet/redresh_icon.svg',
              width: 20.w,
              height: 20.h,
              color: AppColors.textDark,
              fallbackIcon: Icons.refresh,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainBalanceCard() {
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
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Blur effect background circle
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
            padding: EdgeInsetsDirectional.symmetric(horizontal:  16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Label
                Text(
                  'صافي الرصيد المستحق لك',
                  style: const TextStyle().textColorMedium(
                    fontSize: 14.sp,
                    color: const Color(0xFF99A1AF),
                  ),
                ),
                // SizedBox(height: 14.h),

                // Balance Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '145.50',
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
                // SizedBox(height: 14.h),

                // Buttons Row
                Row(
                  children: [
                    // تسوية عهدة button (on the right in RTL)
                    Expanded(
                      child: _buildActionButton(
                        text: 'تسوية عهدة',
                        iconName: 'assets/svg/driver/wallet/settlement_icon.svg',
                        fallbackIcon: Icons.swap_horiz,
                        isPrimary: false,
                        onTap: () {
                          // TODO: Implement settlement
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // سحب أرباح button (on the left in RTL)
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
    return Row(
      children: [
        // عليك (عهد نقدية) card (on the right in RTL)
        Expanded(
          child: WalletSummaryCard(
            title: 'عليك (عهد نقدية)',
            amount: -104.50,
            iconColor: const Color(0xFFFFFBEB),
            iconName: 'assets/svg/driver/wallet/debt_icon.svg',
            fallbackIcon: Icons.remove_circle_outline,
          ),
        ),
        SizedBox(width: 16.w),
        // أرباحك (الصافي) card (on the left in RTL)
        Expanded(
          child: WalletSummaryCard(
            title: 'أرباحك (الصافي)',
            amount: 145.50,
            iconColor: const Color(0xFFF0FDF4),
            iconName: 'assets/svg/driver/wallet/income_icon.svg',
            fallbackIcon: Icons.account_balance_wallet,
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
        color: const Color(0xFFE5E7EB).withOpacity(0.5),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: TabBar(
        controller: _tabController,
        tabAlignment: TabAlignment.fill,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        labelColor: AppColors.textDark,
        unselectedLabelColor: AppColors.textDark,
        labelStyle: const TextStyle().textColorBold(
          fontSize: 14.sp,
          color: AppColors.textDark,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelStyle: const TextStyle().textColorBold(
          fontSize: 14.sp,
          color: AppColors.textDark,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'سجل العمليات', ),
          Tab(text: 'التسويات'),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    // Mock transactions data
    final transactions = [
      {
        'type': 'credit',
        'amount': 9.75,
        'title': 'توصيل طلب #8291',
        'description': '10:30 ص • أرباح توصيل',
        'iconName': 'assets/svg/driver/wallet/income_icon.svg',
        'fallbackIcon': Icons.arrow_upward,
      },
      {
        'type': 'debit',
        'amount': 45.50,
        'title': 'تحصيل كاش #8291',
        'description': '10:32 ص • عهدة نقدية',
        'iconName': 'assets/svg/driver/wallet/debt_icon.svg',
        'fallbackIcon': Icons.arrow_downward,
      },
      {
        'type': 'credit',
        'amount': 50.00,
        'title': 'بونص أسبوعي',
        'description': 'أمس • مكافأة تحقيق الهدف',
        'iconName': 'assets/svg/driver/wallet/income_icon.svg',
        'fallbackIcon': Icons.arrow_upward,
      },
    ];

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: WalletTransactionItem(
            type: transaction['type'] as String,
            amount: transaction['amount'] as double,
            title: transaction['title'] as String,
            description: transaction['description'] as String,
            iconName: transaction['iconName'] as String,
            fallbackIcon: transaction['fallbackIcon'] as IconData,
          ),
        );
      },
    );
  }

  Widget _buildSettlementsTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLightGray,
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
                color: AppColors.lightBackground,
                shape: BoxShape.circle,
              ),
              child: SafeSvgIcon(
                iconName: 'assets/svg/driver/wallet/wallet_empty_icon.svg',
                width: 32.r,
                height: 32.r,
                color: AppColors.textLight,
                fallbackIcon: Icons.account_balance_wallet_outlined,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'لا توجد تسويات معلقة',
              style: const TextStyle().textColorBold(
                fontSize: 18.sp,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'يتم تصفية الحسابات بشكل تلقائي كل يوم أحد',
              style: const TextStyle().textColorNormal(
                fontSize: 14.sp,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}