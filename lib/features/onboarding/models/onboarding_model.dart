import 'package:flutter/material.dart';

class OnboardingItem {
  final String tag;
  final String headingLine1;
  final String headingLine2;
  final String description;
  final String statNumber;
  final String statLabel;
  final String mainEmoji;
  final String secondaryEmoji;
  final String floatingCardEmoji;
  final String floatingCardText;
  final List<Color> backgroundColors;

  const OnboardingItem({
    required this.tag,
    required this.headingLine1,
    required this.headingLine2,
    required this.description,
    required this.statNumber,
    required this.statLabel,
    required this.mainEmoji,
    required this.secondaryEmoji,
    required this.floatingCardEmoji,
    required this.floatingCardText,
    required this.backgroundColors,
  });

  static const List<OnboardingItem> pages = [
    OnboardingItem(
      tag: 'تجربة طعام استثنائية',
      headingLine1: 'أُطلب',
      headingLine2: 'من مطاعمك المفضلة',
      description:
          'اكتشف عالماً من النكهات مع أفضل المطاعم والمقاهي.\nمن الوجبات إلى المعجنات، كل ما تشتهيه في مكان واحد',
      statNumber: '500+',
      statLabel: 'مطعم ومقهى',
      mainEmoji: '🍕',
      secondaryEmoji: '😋',
      floatingCardEmoji: '🍕',
      floatingCardText: 'بيـتـزا',
      backgroundColors: [Color(0xFFFFF8E1), Color(0xFFFFECB3), Color(0xFFFFE0B2)],
    ),
    OnboardingItem(
      tag: 'خدمة توصيل متميزة',
      headingLine1: 'توصيل',
      headingLine2: 'سريع لباب بيتك',
      description:
          'استمتع بتوصيل سريع وموثوق لجميع طلباتك.\nفريقنا يضمن وصول طلبك طازجاً وفي الوقت المحدد',
      statNumber: '30',
      statLabel: 'دقيقة توصيل',
      mainEmoji: '🛵',
      secondaryEmoji: '📦',
      floatingCardEmoji: '🚀',
      floatingCardText: 'سريع',
      backgroundColors: [Color(0xFFE8EAF6), Color(0xFFC5CAE9), Color(0xFFB3BCF5)],
    ),
    OnboardingItem(
      tag: 'طرق دفع متعددة',
      headingLine1: 'ادفع',
      headingLine2: 'بسهولة وأمان',
      description:
          'طرق دفع متعددة وآمنة تناسب احتياجاتك.\nنقداً أو إلكترونياً، الخيار لك بكل سهولة',
      statNumber: '100%',
      statLabel: 'آمن وموثوق',
      mainEmoji: '💳',
      secondaryEmoji: '✨',
      floatingCardEmoji: '🔒',
      floatingCardText: 'آمــن',
      backgroundColors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
    ),
  ];
}
