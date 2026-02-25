import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../models/onboarding_model.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  final pages = OnboardingItem.pages;

  bool get isLastPage => currentPage.value == pages.length - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (isLastPage) {
      completeOnboarding();
    } else {
      pageController.animateToPage(
        currentPage.value + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    completeOnboarding();
  }

  void completeOnboarding() {
    GetStorage().write(AppConstants.onboardingSeenKey, true);
    Get.offAllNamed(AppRoutes.addressSelection);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
