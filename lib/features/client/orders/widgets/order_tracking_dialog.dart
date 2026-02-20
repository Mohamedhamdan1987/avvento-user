import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:avvento/core/enums/order_status.dart';
import '../../../../core/constants/app_colors.dart';

class OrderTrackingDialog extends StatelessWidget {
  final String orderId;
  final OrderStatus status;
  final String? driverName;
  final String? driverPhone;
  final String? driverImageUrl;
  final ScrollController scrollController;

  const OrderTrackingDialog({
    super.key,
    required this.orderId,
    required this.status,
    required this.scrollController,
    this.driverName,
    this.driverPhone,
    this.driverImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // Drag Handle (pinned)
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 48.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),

          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Text(
                    _getStatusTitle(),
                    style: TextStyle().textColorBold(
                      fontSize: 20.sp,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'طلبك رقم #$orderId',
                    style: TextStyle().textColorNormal(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),

          // Animation Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _buildAnimationSection(context),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),

          // Driver Info (if applicable)
          if (status == OrderStatus.onTheWay ||
              status == OrderStatus.awaitingDelivery)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: _buildDriverInfo(context),
              ),
            ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),

          // Timeline
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _buildTimeline(context),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }

  String _getStatusTitle() {
    return status.label;
  }

  /// مسار ملف Lottie حسب حالة الطلب (من مجلد assets/loti_files)
  String? _getLottieAssetPath() {
    switch (status) {
      case OrderStatus.pendingRestaurant:
        return 'assets/loti_files/pendingRestaurant.json';
      case OrderStatus.confirmed:
        return 'assets/loti_files/confirmed.json';
      case OrderStatus.preparing:
        return 'assets/loti_files/preparing.json';
      case OrderStatus.deliveryReceived:
        return 'assets/loti_files/deliveryReceived.json';
      case OrderStatus.delivered:
        return 'assets/loti_files/delivered.json';
      default:
        return null;
    }
  }

  Widget _buildAnimationSection(BuildContext context) {
    final theme = Theme.of(context);
    final lottiePath = _getLottieAssetPath();

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: theme.dividerColor, width: 0.76.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: lottiePath != null
          ? _buildLottieSection(context, lottiePath)
          : _getFallbackAnimationWidget(context),
    );
  }

  /// عرض Lottie بشكل احترافي مع نص فرعي عند الحاجة
  Widget _buildLottieSection(BuildContext context, String assetPath) {
    final theme = Theme.of(context);
    final subtitle = _getLottieSubtitle();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Lottie.asset(
              assetPath,
              fit: BoxFit.contain,
              repeat: true,
              options: LottieOptions(enableMergePaths: true),
              addRepaintBoundary: true,
              height: 140.h,
            ),
          ),
        ),
        if (subtitle != null) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle().textColorBold(
                fontSize: 14.sp,
                color: theme.textTheme.titleMedium?.color ?? AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String? _getLottieSubtitle() {
    switch (status) {
      case OrderStatus.confirmed:
        return 'تم القبول!';
      case OrderStatus.preparing:
        return 'جاري التحضير...';
      case OrderStatus.deliveryReceived:
        return 'تم استلام الطلب بنجاح!';
      case OrderStatus.delivered:
        return 'بالهناء والشفاء!';
      default:
        return null;
    }
  }

  /// عناصر الحركة للحالات التي لا يوجد لها ملف Lottie
  Widget _getFallbackAnimationWidget(BuildContext context) {
    switch (status) {
      case OrderStatus.pendingRestaurant:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3.w),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'ننتظر رد المطعم...',
                style: TextStyle().textColorBold(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        );

      case OrderStatus.onTheWay:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delivery_dining, size: 72.sp, color: AppColors.primary),
              SizedBox(height: 8.h),
              Text(
                'في الطريق إليك',
                style: TextStyle().textColorBold(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        );

      case OrderStatus.awaitingDelivery:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 72.sp, color: AppColors.primary),
              SizedBox(height: 8.h),
              Text(
                'الكابتن أفينتو بالخارج...',
                style: TextStyle().textColorBold(
                  fontSize: 12.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );

      case OrderStatus.cancelled:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel_outlined, size: 64.sp, color: Theme.of(context).colorScheme.error),
              SizedBox(height: 8.h),
              Text(
                'تم إلغاء الطلب',
                style: TextStyle().textColorBold(
                  fontSize: 16.sp,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTimeline(BuildContext context) {
    return Container(
      // height: 360.h,
      child: Stack(
        children: [
          // Vertical Line
          PositionedDirectional(
            start: 20.w,
            top: 12.h,
            child: Container(
              width: 2.w,
              height: 312.h,
              color: Theme.of(context).dividerColor,
            ),
          ),

          // Timeline Items
          Column(
            children: [
              _buildTimelineItem(
                context,
                time: '12:30',
                title: 'بانتظار قبول المطعم',
                isActive: status.index >= 0,
                isCurrent: status == OrderStatus.pendingRestaurant,
                icon: "assets/svg/client/orders/pending_acceptance.svg",
              ),

              SizedBox(height: 24.h),
              _buildTimelineItem(
                context,
                time: '12:31',
                title: 'تم تأكيد الطلب',
                isActive: status.index >= 1,
                isCurrent: status == OrderStatus.confirmed,
                icon: "assets/svg/client/orders/confirmed.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                context,
                time: '12:35',
                title: 'جاري التحضير',
                isActive: status.index >= 2,
                isCurrent: status == OrderStatus.preparing,
                icon: "assets/svg/client/orders/preparing.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                context,
                time: '12:45',
                title: 'استلم السائق الطلب',
                isActive: status.index >= 3,
                isCurrent: status == OrderStatus.deliveryReceived,
                icon: "assets/svg/client/orders/delivered.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                context,
                time: '12:50',
                title: 'في الطريق إليك',
                isActive: status.index >= 4,
                isCurrent: status == OrderStatus.onTheWay,
                icon: "assets/svg/client/orders/on_the_way.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                context,
                time: '01:05',
                title: 'في انتظار التسليم',
                isActive: status.index >= 5,
                isCurrent: status == OrderStatus.awaitingDelivery,
                icon: "assets/svg/client/orders/waiting_pickup.svg",
              ),
              SizedBox(height: 24.h),
              _buildTimelineItem(
                context,
                time: '01:10',
                title: 'تم تسليم الطلب',
                isActive: status.index >= 6,
                isCurrent: status == OrderStatus.delivered,
                icon: "assets/svg/client/orders/delivered.svg",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String time,
    required String title,
    required bool isActive,
    required bool isCurrent,
    required String icon,
  }) {
    return Row(
      children: [
        // Icon
        Container(
          width: isCurrent ? 44.w : 40.w,
          height: isCurrent ? 44.h : 40.h,
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.primary
                : (isActive ? Color(0xFF00C950) : Theme.of(context).cardColor),
            shape: BoxShape.circle,
            border: isActive && !isCurrent
                ? Border.all(color: Color(0xFF00C950), width: 1.5.w)
                : (isCurrent
                      ? Border.all(color: Theme.of(context).dividerColor, width: 1.5.w)
                      : Border.all(color: Theme.of(context).dividerColor, width: 1.5.w)),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: SvgIcon(
              iconName: icon,
              color: isCurrent
                  ? Colors.white
                  : (isActive ? Colors.white : Theme.of(context).dividerColor),
              height: isCurrent ? 18.sp : 16.sp,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Title
        Expanded(
          child: Text(
            title,
            style: TextStyle().textColorBold(
              fontSize: 14.sp,
              color: isCurrent
                  ? Theme.of(context).textTheme.titleLarge?.color
                  : (isActive
                        ? Theme.of(context).textTheme.bodySmall?.color
                        : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.3)),
            ),
          ),
        ),
        // Time
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            time,
            style: TextStyle().textColorBold(
              fontSize: 10.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  Widget _buildDriverInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 0.76.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Action Buttons
          Row(
            children: [
              // Phone Call Button
              GestureDetector(
                onTap: () async {
                  if (driverPhone != null && driverPhone!.isNotEmpty) {
                    final uri = Uri(scheme: 'tel', path: driverPhone);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  }
                },
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFFF4500),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phone, color: Colors.white, size: 16.sp),
                ),
              ),
              SizedBox(width: 8.w),
              // Chat Button
              GestureDetector(
                onTap: () {
                  // TODO: Implement chat with driver
                },
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          // Driver Info
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        driverName ?? 'كابتن أفينتو',
                        style: TextStyle().textColorBold(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      if (driverPhone != null && driverPhone!.isNotEmpty)
                        Text(
                          driverPhone!,
                          style: TextStyle().textColorNormal(
                            fontSize: 10.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          textAlign: TextAlign.end,
                          textDirection: TextDirection.ltr,
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Driver Photo
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5.w,
                    ),
                  ),
                  child: ClipOval(
                    child: driverImageUrl != null && driverImageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: driverImageUrl!,
                            fit: BoxFit.cover,
                            width: 44.w,
                            height: 44.h,
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 24.sp,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
