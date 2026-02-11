import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/order_status.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/reusable/safe_svg_icon.dart';
import '../models/order_model.dart';
import '../controllers/orders_controller.dart';
import '../../pages/controllers/client_nav_bar_controller.dart';

/// ودجت عائمة قابلة للسحب: بعد ٥ ثوانٍ تصغر لحجم الدائرة فقط.
/// أول ضغطة: ترجع للشكل الكامل. ثاني ضغطة: تفتح صفحة الطلبات.
/// يمكن سحبها لأي مكان في الشاشة.
class FloatingActiveOrderBanner extends StatefulWidget {
  const FloatingActiveOrderBanner({super.key});

  @override
  State<FloatingActiveOrderBanner> createState() =>
      _FloatingActiveOrderBannerState();
}

class _FloatingActiveOrderBannerState extends State<FloatingActiveOrderBanner> {
  bool _collapsed = false;
  Timer? _collapseTimer;
  static const _collapseAfter = Duration(seconds: 5);
  static const _animationDuration = Duration(milliseconds: 400);
  static const _snapDuration = Duration(milliseconds: 300);

  // Position tracking for drag
  double _top = -1; // -1 means not yet initialized
  double _left = -1;
  bool _isDragging = false;
  bool _positionInitialized = false;
  bool _snappedToRight = false; // which edge the banner is snapped to
  Size _screenSize = Size.zero; // cached for collapse/expand adjustments

  @override
  void initState() {
    super.initState();
    _startCollapseTimer();
  }

  void _initPosition(Size screenSize) {
    if (!_positionInitialized) {
      final safePadding = MediaQuery.of(context).padding.top;
      _top = safePadding*4;
      _left = 16.w;
      _positionInitialized = true;
    }
  }

  void _startCollapseTimer() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(_collapseAfter, () {
      if (mounted) {
        setState(() {
          _collapsed = true;
          _adjustLeftForCollapseState(_screenSize);
        });
      }
    });
  }

  void _onTap() {
    if (_isDragging) return;
    if (_collapsed) {
      setState(() {
        _collapsed = false;
        _adjustLeftForCollapseState(_screenSize);
      });
      _startCollapseTimer();
    } else {
      _navigateToOrders();
    }
  }

  /// Snap the banner to the nearest horizontal edge
  void _snapToEdge(Size screenSize) {
    final sizeR = 48.r;
    final currentWidth = _collapsed ? sizeR : (screenSize.width - 32.w);
    final centerX = _left + currentWidth / 2;
    final screenCenter = screenSize.width / 2;
    final margin = 16.w;

    setState(() {
      if (centerX < screenCenter) {
        _snappedToRight = false;
        _left = margin;
      } else {
        _snappedToRight = true;
        _left = screenSize.width - currentWidth - margin;
      }

      // Clamp vertical position
      final safePadding = MediaQuery.of(context).padding.top;
      final bottomPadding = MediaQuery.of(context).padding.bottom;
      final minTop = safePadding + 4.h;
      final maxTop = screenSize.height - sizeR - bottomPadding - 16.h;
      _top = _top.clamp(minTop, maxTop);
    });
  }

  /// Recalculate _left when collapse state changes so the banner
  /// expands toward the opposite side of the edge it's snapped to.
  void _adjustLeftForCollapseState(Size screenSize) {
    final sizeR = 48.r;
    final expandedWidth = screenSize.width - 32.w;
    final margin = 16.w;

    if (_collapsed) {
      // Collapsing: move circle to the snapped edge
      if (_snappedToRight) {
        _left = screenSize.width - sizeR - margin;
      } else {
        _left = margin;
      }
    } else {
      // Expanding: open toward opposite side from the snapped edge
      if (_snappedToRight) {
        _left = screenSize.width - expandedWidth - margin;
      } else {
        _left = margin;
      }
    }
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  static String _statusBannerText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingRestaurant:
        return 'طلبك بانتظار قبول المطعم..';
      case OrderStatus.confirmed:
        return 'طلبك تم تأكيده..';
      case OrderStatus.preparing:
        return 'طلبك جاري التحضير..';
      case OrderStatus.deliveryReceived:
      case OrderStatus.awaitingDelivery:
        return 'طلبك جاري التحضير..';
      case OrderStatus.onTheWay:
        return 'طلبك في الطريق إليك..';
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return 'طلبك';
    }
  }

  /// مسار أيقونة SVG حسب حالة الطلب.
  static String _statusIconPath(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingRestaurant:
        return 'assets/svg/client/orders/pending_acceptance.svg';
      case OrderStatus.confirmed:
        return 'assets/svg/client/orders/confirmed.svg';
      case OrderStatus.preparing:
        return 'assets/svg/client/orders/preparing.svg';
      case OrderStatus.deliveryReceived:
        return 'assets/svg/client/orders/delivered.svg';
      case OrderStatus.onTheWay:
        return 'assets/svg/client/orders/on_the_way.svg';
      case OrderStatus.awaitingDelivery:
        return 'assets/svg/client/orders/waiting_pickup.svg';
      case OrderStatus.delivered:
        return 'assets/svg/client/orders/delivered.svg';
      case OrderStatus.cancelled:
        return 'assets/svg/client/orders/cancel_icon.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OrdersController>()) {
      return const SizedBox.shrink();
    }
    final ordersController = Get.find<OrdersController>();
    return Obx(() {
      if (ordersController.activeOrders.isEmpty) {
        return const SizedBox.shrink();
      }
      final order = _latestActiveOrder(ordersController.activeOrders);
      if (order == null) return const SizedBox.shrink();
      final status = OrderStatus.fromString(order.status);
      final bannerText = _statusBannerText(status);

      return LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
          _screenSize = screenSize;
          _initPosition(screenSize);

          return Stack(
            children: [
              AnimatedPositioned(
                duration: _isDragging ? Duration.zero : _snapDuration,
                curve: Curves.easeOutCubic,
                top: _top,
                left: _left,
                child: GestureDetector(
                  onTap: _onTap,
                  onPanStart: (_) {
                    _isDragging = true;
                    _collapseTimer?.cancel();
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _top += details.delta.dy;
                      _left += details.delta.dx;
                    });
                  },
                  onPanEnd: (_) {
                    _isDragging = false;
                    _snapToEdge(screenSize);
                    _startCollapseTimer();
                  },
                  child: _buildBanner(context, bannerText, status),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  /// ودجت واحدة متغيرة الحجم: منكمش = دائرة فقط، مفتوح = نص + دائرة.
  /// الأيقونة تتغير حسب حالة الطلب (SVG).
  Widget _buildBanner(
    BuildContext context,
    String bannerText,
    OrderStatus status,
  ) {
    final sizeR = 48.r;
    final maxW = MediaQuery.sizeOf(context).width - 32.w;
    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOutCubic,
      width: _collapsed ? sizeR : null,
      height: sizeR,
      constraints: _collapsed
          ? BoxConstraints.tight(Size(sizeR, sizeR))
          : BoxConstraints(maxWidth: maxW),
      padding: _collapsed
          ? EdgeInsets.all((sizeR - 24.r) / 2)
          : EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minWidthForContent = 10.w + 10.r * 2 + 22.r + 40;
          final hasSpaceForText = constraints.maxWidth >= minWidthForContent;
          final showText = !_collapsed && hasSpaceForText;
          return Row(
            mainAxisAlignment: _collapsed || !showText
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              if (showText)
                Flexible(
                  child: Text(
                    bannerText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (showText) SizedBox(width: 10.w),
              SafeSvgIcon(
                iconName: _statusIconPath(status),
                width: 24.r,
                height: 24.r,
                color: AppColors.white,
                fallbackIcon: Icons.schedule_rounded,
              )
            ],
          );
        },
      ),
    );
  }

  OrderModel? _latestActiveOrder(List<OrderModel> orders) {
    if (orders.isEmpty) return null;
    final sorted = List<OrderModel>.from(orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.isNotEmpty ? sorted.first : null;
  }

  void _navigateToOrders() {
    if (Get.isRegistered<ClientNavBarController>()) {
      Get.find<ClientNavBarController>().goToOrders();
      Get.until((route) => route.settings.name == AppRoutes.clientNavBar);
    } else {
      Get.offAllNamed(AppRoutes.clientNavBar, arguments: {'tabIndex': 1});
    }
  }
}
