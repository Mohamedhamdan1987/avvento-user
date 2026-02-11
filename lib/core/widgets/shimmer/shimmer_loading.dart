import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Base shimmer wrapper that applies a shimmer animation effect.
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!),
      highlightColor: highlightColor ?? (isDark ? Colors.grey[700]! : Colors.grey[100]!),
      child: child,
    );
  }
}

/// A shimmer placeholder box with rounded corners.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );
  }
}

/// A shimmer circle placeholder.
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Home Page Shimmer
// ──────────────────────────────────────────────────────

/// Shimmer for the home page content (promo + favorites + discounts).
class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promo card shimmer
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ShimmerBox(width: double.infinity, height: 216.h, borderRadius: 20),
            ),
            SizedBox(height: 16.h),
            // Promo indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: ShimmerBox(width: i == 0 ? 20.w : 6.w, height: 6.h, borderRadius: 10),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Section header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 120.w, height: 16.h, borderRadius: 8),
                  ShimmerBox(width: 60.w, height: 14.h, borderRadius: 8),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Favorite restaurants (circles)
            SizedBox(
              height: 110.h,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (_, __) => Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Column(
                    children: [
                      ShimmerCircle(size: 70.w),
                      SizedBox(height: 8.h),
                      ShimmerBox(width: 50.w, height: 10.h, borderRadius: 6),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Discounts section header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 140.w, height: 16.h, borderRadius: 8),
                  ShimmerBox(width: 60.w, height: 14.h, borderRadius: 8),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Discount cards
            SizedBox(
              height: 176.h,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (_, __) => Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: ShimmerBox(width: 150.w, height: 176.h, borderRadius: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Restaurants Page Shimmer
// ──────────────────────────────────────────────────────

/// Shimmer for a single restaurant card.
class RestaurantCardShimmer extends StatelessWidget {
  const RestaurantCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ShimmerBox(width: double.infinity, height: 130, borderRadius: 12),
          SizedBox(height: 12.h),
          // Name row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 120.w, height: 16.h, borderRadius: 8),
                ShimmerBox(width: 100.w, height: 12.h, borderRadius: 8),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // Details row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                ShimmerBox(width: 80.w, height: 12.h, borderRadius: 6),
                SizedBox(width: 12.w),
                ShimmerBox(width: 80.w, height: 12.h, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer for the full restaurants list page.
class RestaurantsPageShimmer extends StatelessWidget {
  const RestaurantsPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stories section
            Padding(
              padding: EdgeInsets.only(right: 24.w, top: 16.h, bottom: 8.h),
              child: ShimmerBox(width: 120.w, height: 18.h, borderRadius: 8),
            ),
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                itemBuilder: (_, __) => Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: Column(
                    children: [
                      ShimmerCircle(size: 60.w),
                      SizedBox(height: 4.h),
                      ShimmerBox(width: 50.w, height: 10.h, borderRadius: 6),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Featured section header
            Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: ShimmerBox(width: 80.w, height: 18.h, borderRadius: 8),
            ),
            SizedBox(height: 8.h),
            // Featured horizontal cards
            SizedBox(
              height: 215.h,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (_, __) => Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: ShimmerBox(
                    width: MediaQuery.of(context).size.width * 0.82,
                    height: 200.h,
                    borderRadius: 12,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // All restaurants section
            Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: ShimmerBox(width: 100.w, height: 18.h, borderRadius: 8),
            ),
            SizedBox(height: 8.h),
            // Restaurant cards
            ...List.generate(4, (_) => const RestaurantCardShimmer()),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Restaurant Details Shimmer
// ──────────────────────────────────────────────────────

/// Shimmer for the restaurant details page.
class RestaurantDetailsShimmer extends StatelessWidget {
  const RestaurantDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image placeholder
            ShimmerBox(width: double.infinity, height: 250.h, borderRadius: 0),
            SizedBox(height: 60.h),
            // Stats row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ShimmerBox(width: double.infinity, height: 70.h, borderRadius: 21),
            ),
            SizedBox(height: 24.h),
            // Browse menu section title
            Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: ShimmerBox(width: 100.w, height: 18.h, borderRadius: 8),
            ),
            SizedBox(height: 16.h),
            // Menu categories (horizontal)
            SizedBox(
              height: 140.h,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (_, __) => Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: ShimmerBox(width: 120.w, height: 140.h, borderRadius: 24),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            // All items section title
            Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: ShimmerBox(width: 110.w, height: 18.h, borderRadius: 8),
            ),
            SizedBox(height: 16.h),
            // Item cards
            ...List.generate(4, (_) => _buildItemShimmer()),
          ],
        ),
      ),
    );
  }

  Widget _buildItemShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        children: [
          ShimmerBox(width: 96.w, height: 96.h, borderRadius: 20),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140.w, height: 16.h, borderRadius: 8),
                SizedBox(height: 8.h),
                ShimmerBox(width: double.infinity, height: 12.h, borderRadius: 6),
                SizedBox(height: 8.h),
                ShimmerBox(width: 60.w, height: 18.h, borderRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer specifically for menu categories horizontal list.
class MenuCategoriesShimmer extends StatelessWidget {
  const MenuCategoriesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: 16.w),
        itemBuilder: (_, __) => ShimmerBox(width: 120.w, height: 140.h, borderRadius: 24),
      ),
    );
  }
}

/// Shimmer for items list in restaurant details.
class MenuItemsShimmer extends StatelessWidget {
  const MenuItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              children: [
                ShimmerBox(width: 96.w, height: 96.h, borderRadius: 20),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 140.w, height: 16.h, borderRadius: 8),
                      SizedBox(height: 8.h),
                      ShimmerBox(width: double.infinity, height: 12.h, borderRadius: 6),
                      SizedBox(height: 8.h),
                      ShimmerBox(width: 60.w, height: 18.h, borderRadius: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Cart Page Shimmer
// ──────────────────────────────────────────────────────

/// Shimmer for the cart list page.
class CartListShimmer extends StatelessWidget {
  const CartListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 29.h),
            // Header shimmer
            ShimmerBox(width: 200.w, height: 24.h, borderRadius: 8),
            SizedBox(height: 8.h),
            ShimmerBox(width: 160.w, height: 24.h, borderRadius: 8),
            SizedBox(height: 16.h),
            ShimmerBox(width: 220.w, height: 14.h, borderRadius: 6),
            SizedBox(height: 33.h),
            // Cart cards
            ...List.generate(3, (_) => _buildCartCardShimmer()),
          ],
        ),
      ),
    );
  }

  Widget _buildCartCardShimmer() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ShimmerBox(width: 56.w, height: 56.h, borderRadius: 16),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 120.w, height: 16.h, borderRadius: 8),
                      SizedBox(height: 8.h),
                      ShimmerBox(width: 80.w, height: 12.h, borderRadius: 6),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ShimmerBox(width: 50.w, height: 20.h, borderRadius: 8),
                    SizedBox(height: 4.h),
                    ShimmerBox(width: 70.w, height: 14.h, borderRadius: 8),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ShimmerBox(width: double.infinity, height: 1, borderRadius: 0),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 100.w, height: 14.h, borderRadius: 6),
                ShimmerCircle(size: 40.w),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Cart Details Shimmer
// ──────────────────────────────────────────────────────

/// Shimmer for the restaurant cart details page.
class CartDetailsShimmer extends StatelessWidget {
  const CartDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 13.h),
            // Restaurant header
            Container(
              height: 73.h,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  ShimmerCircle(size: 40.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShimmerBox(width: 120.w, height: 14.h, borderRadius: 8),
                        SizedBox(height: 6.h),
                        ShimmerBox(width: 80.w, height: 12.h, borderRadius: 6),
                      ],
                    ),
                  ),
                  ShimmerBox(width: 24.w, height: 24.h, borderRadius: 12),
                ],
              ),
            ),
            SizedBox(height: 13.h),
            // Cart items
            ...List.generate(3, (_) => _buildCartItemShimmer()),
            SizedBox(height: 13.h),
            // Add items button
            ShimmerBox(width: double.infinity, height: 36.h, borderRadius: 14),
            SizedBox(height: 24.h),
            // Drinks section title
            ShimmerBox(width: 100.w, height: 16.h, borderRadius: 8),
            SizedBox(height: 12.h),
            // Drinks horizontal list
            SizedBox(
              height: 157.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (_, __) => ShimmerBox(width: 140.w, height: 149.h, borderRadius: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemShimmer() {
    return Padding(
      padding: EdgeInsets.only(bottom: 13.h),
      child: Container(
        height: 125.h,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            ShimmerBox(width: 80.w, height: 80.h, borderRadius: 14),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerBox(width: 120.w, height: 14.h, borderRadius: 8),
                  SizedBox(height: 8.h),
                  ShimmerBox(width: 70.w, height: 14.h, borderRadius: 8),
                  SizedBox(height: 12.h),
                  ShimmerBox(width: 100.w, height: 36.h, borderRadius: 14),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            ShimmerBox(width: 16.w, height: 16.h, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Shimmer for the suggested drinks horizontal list.
class DrinksShimmer extends StatelessWidget {
  const DrinksShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 100.w, height: 16.h, borderRadius: 8),
          SizedBox(height: 12.h),
          SizedBox(
            height: 157.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (_, __) => Container(
                width: 140.w,
                height: 149.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: ShimmerBox(width: double.infinity, height: 80.h, borderRadius: 4),
                    ),
                    SizedBox(height: 12.h),
                    ShimmerBox(width: 80.w, height: 12.h, borderRadius: 6),
                    SizedBox(height: 4.h),
                    ShimmerBox(width: 50.w, height: 12.h, borderRadius: 6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Orders Page Shimmer
// ──────────────────────────────────────────────────────

/// Shimmer for the orders list.
class OrdersListShimmer extends StatelessWidget {
  const OrdersListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: List.generate(4, (_) => _buildOrderCardShimmer()),
        ),
      ),
    );
  }

  Widget _buildOrderCardShimmer() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ShimmerCircle(size: 48.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 130.w, height: 16.h, borderRadius: 8),
                      SizedBox(height: 6.h),
                      ShimmerBox(width: 90.w, height: 12.h, borderRadius: 6),
                    ],
                  ),
                ),
                ShimmerBox(width: 60.w, height: 24.h, borderRadius: 12),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 80.w, height: 12.h, borderRadius: 6),
                ShimmerBox(width: 60.w, height: 12.h, borderRadius: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Wallet Page Shimmer
// ──────────────────────────────────────────────────────

/// Shimmer for wallet pages (client & driver).
class WalletPageShimmer extends StatelessWidget {
  const WalletPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            // Balance card shimmer
            ShimmerBox(width: double.infinity, height: 180.h, borderRadius: 24),
            SizedBox(height: 32.h),
            // Transactions section title
            ShimmerBox(width: 130.w, height: 18.h, borderRadius: 8),
            SizedBox(height: 16.h),
            // Transactions
            ...List.generate(5, (_) => _buildTransactionShimmer()),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionShimmer() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          ShimmerCircle(size: 44.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120.w, height: 14.h, borderRadius: 6),
                SizedBox(height: 6.h),
                ShimmerBox(width: 80.w, height: 12.h, borderRadius: 6),
              ],
            ),
          ),
          ShimmerBox(width: 60.w, height: 16.h, borderRadius: 8),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Notifications Page Shimmer
// ──────────────────────────────────────────────────────

/// Shimmer for the notifications list.
class NotificationsListShimmer extends StatelessWidget {
  const NotificationsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: List.generate(5, (_) => _buildNotificationShimmer()),
        ),
      ),
    );
  }

  Widget _buildNotificationShimmer() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 48.w, height: 48.h, borderRadius: 8),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 180.w, height: 16.h, borderRadius: 8),
                  SizedBox(height: 6.h),
                  ShimmerBox(width: double.infinity, height: 12.h, borderRadius: 6),
                  SizedBox(height: 6.h),
                  ShimmerBox(width: 140.w, height: 12.h, borderRadius: 6),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      ShimmerBox(width: 60.w, height: 10.h, borderRadius: 4),
                      SizedBox(width: 16.w),
                      ShimmerBox(width: 80.w, height: 10.h, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Address List Shimmer
// ──────────────────────────────────────────────────────

/// Shimmer for the address list page.
class AddressListShimmer extends StatelessWidget {
  const AddressListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          children: List.generate(4, (_) => _buildAddressCardShimmer()),
        ),
      ),
    );
  }

  Widget _buildAddressCardShimmer() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            ShimmerCircle(size: 48.w),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 100.w, height: 16.h, borderRadius: 8),
                  SizedBox(height: 6.h),
                  ShimmerBox(width: 180.w, height: 12.h, borderRadius: 6),
                ],
              ),
            ),
            ShimmerBox(width: 24.w, height: 24.h, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Support/Chat Shimmer
// ──────────────────────────────────────────────────────

/// Shimmer for support/chat page messages.
class SupportChatShimmer extends StatelessWidget {
  const SupportChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          children: [
            // Support messages (left aligned)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ShimmerBox(width: 220.w, height: 48.h, borderRadius: 16),
            ),
            SizedBox(height: 12.h),
            // User messages (right aligned)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: ShimmerBox(width: 180.w, height: 40.h, borderRadius: 16),
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ShimmerBox(width: 250.w, height: 56.h, borderRadius: 16),
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: ShimmerBox(width: 160.w, height: 36.h, borderRadius: 16),
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ShimmerBox(width: 200.w, height: 44.h, borderRadius: 16),
            ),
          ],
        ),
      ),
    );
  }
}
