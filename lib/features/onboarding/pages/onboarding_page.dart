import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/onboarding_controller.dart';
import '../models/onboarding_model.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageContent(
                    item: controller.pages[index],
                    pageIndex: index,
                    totalPages: controller.pages.length,
                  );
                },
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 12.h,
                right: 24.w,
                left: 24.w,
                child: _TopBar(controller: controller),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final OnboardingController controller;

  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => _PageIndicators(
              currentPage: controller.currentPage.value,
              totalPages: controller.pages.length,
            )),
        GestureDetector(
          onTap: controller.skip,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              'تخطي',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPlaceholder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageIndicators extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _PageIndicators({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsetsDirectional.only(
            start: index == 0 ? 0 : 5.w,
          ),
          width: isActive ? 40.w : 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6938D3) : AppColors.borderGray,
            borderRadius: BorderRadius.circular(100.r),
          ),
        );
      }),
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  final OnboardingItem item;
  final int pageIndex;
  final int totalPages;

  const _OnboardingPageContent({
    required this.item,
    required this.pageIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return Column(
      children: [
        Expanded(
          flex: 57,
          child: _ImageSection(
            item: item,
            pageIndex: pageIndex,
            totalPages: totalPages,
          ),
        ),
        Expanded(
          flex: 43,
          child: _ContentSection(
            item: item,
            controller: controller,
          ),
        ),
      ],
    );
  }
}

class _ImageSection extends StatelessWidget {
  final OnboardingItem item;
  final int pageIndex;
  final int totalPages;

  const _ImageSection({
    required this.item,
    required this.pageIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item.backgroundColors,
              ),
            ),
          ),
        ),

        // Scattered decorative emojis
        ..._buildScatteredEmojis(),

        // Main hero emoji (large, centered)
        Positioned(
          top: 160.h,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  item.mainEmoji,
                  style: TextStyle(fontSize: 80.sp, height: 1.2),
                ),
              ),
            ),
          ),
        ),

        // Gradient overlay: transparent → white (bottom fade)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.6),
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 0.5, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // Page counter badge (top-left visual)
        Positioned(
          left: 24.w,
          top: MediaQuery.of(context).padding.top + 50.h,
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderLightGray,
                width: 0.76,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${pageIndex + 1}/$totalPages',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF364153),
                ),
              ),
            ),
          ),
        ),

        // Floating emoji card (right area)
        Positioned(
          right: 40.w,
          top: 180.h,
          child: _FloatingEmojiCard(
            emoji: item.floatingCardEmoji,
            label: item.floatingCardText,
          ),
        ),

        // Secondary emoji (floating)
        Positioned(
          right: 24.w,
          top: 230.h,
          child: Text(
            item.secondaryEmoji,
            style: TextStyle(fontSize: 40.sp),
          ),
        ),

        // Stat card (bottom-left area)
        Positioned(
          left: 40.w,
          bottom: 20.h,
          child: _FloatingStatCard(
            number: item.statNumber,
            label: item.statLabel,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildScatteredEmojis() {
    final emojis = _getDecorativeEmojis();
    final positions = [
      Positioned(left: 30.w, top: 80.h, child: _DecorEmoji(emojis[0], 28)),
      Positioned(right: 20.w, top: 100.h, child: _DecorEmoji(emojis[1], 22)),
      Positioned(left: 60.w, top: 280.h, child: _DecorEmoji(emojis[2], 24)),
      Positioned(right: 70.w, bottom: 80.h, child: _DecorEmoji(emojis[3], 20)),
      Positioned(left: 160.w, top: 60.h, child: _DecorEmoji(emojis[4], 18)),
    ];
    return positions;
  }

  List<String> _getDecorativeEmojis() {
    switch (pageIndex) {
      case 0:
        return ['🍔', '🥗', '☕', '🧁', '🍜'];
      case 1:
        return ['📍', '⏱️', '🏠', '✅', '🗺️'];
      case 2:
        return ['💰', '🏦', '🔐', '💎', '📱'];
      default:
        return ['⭐', '✨', '💫', '🌟', '⚡'];
    }
  }
}

class _DecorEmoji extends StatelessWidget {
  final String emoji;
  final double size;

  const _DecorEmoji(this.emoji, this.size);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Text(
        emoji,
        style: TextStyle(fontSize: size.sp),
      ),
    );
  }
}

class _FloatingEmojiCard extends StatelessWidget {
  final String emoji;
  final String label;

  const _FloatingEmojiCard({
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 114.w,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderLightGray,
          width: 0.76,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 40.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FloatingStatCard extends StatelessWidget {
  final String number;
  final String label;

  const _FloatingStatCard({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 114.w,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderLightGray,
          width: 0.76,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            number,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 30.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.1,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  final OnboardingItem item;
  final OnboardingController controller;

  const _ContentSection({
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),

          // Tag row: text + purple dot
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                item.tag,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Heading line 1 (large)
          SizedBox(
            width: double.infinity,
            child: Text(
              item.headingLine1,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 36.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1.35,
              ),
            ),
          ),

          // Heading line 2 (slightly smaller)
          SizedBox(
            width: double.infinity,
            child: Text(
              item.headingLine2,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 30.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1.35,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Description
          SizedBox(
            width: double.infinity,
            child: Text(
              item.description,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMedium,
                height: 1.85,
              ),
            ),
          ),

          const Spacer(),

          // Next / Start button
          Obx(() => _NextButton(
                isLastPage: controller.isLastPage,
                onTap: controller.nextPage,
              )),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onTap;

  const _NextButton({
    required this.isLastPage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 68.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.25),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastPage ? 'ابدأ الآن' : 'التالي',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.white,
              size: 15.sp,
            ),
          ],
        ),
      ),
    );
  }
}
