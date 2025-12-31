# برومبت لإنشاء صفحات تفاصيل في تطبيق Flutter (RTL)

استخدم هذا البرومبت عند الحاجة لإنشاء صفحة تفاصيل جديدة مشابهة لصفحة `restaurant_details_screen.dart`.

---

## البرومبت:

```
أريد إنشاء صفحة تفاصيل جديدة في تطبيق Flutter باستخدام نفس البنية والأنماط المستخدمة في المشروع.

## المتطلبات الأساسية:

### 1. البنية والملفات المستخدمة:
- استخدم `lib/core/theme/app_text_styles.dart` لجميع أنماط النصوص
- استخدم `lib/core/widgets/reusable/custom_button_app/custom_button_app.dart` للأزرار العادية
- استخدم `lib/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart` لأزرار الأيقونات
- استخدم `lib/core/widgets/reusable/svg_icon.dart` لعرض الأيقونات SVG

### 2. القياسات والمسافات:
- استخدم دائماً `.h` للارتفاعات والمسافات العمودية
- استخدم دائماً `.w` للعروض والمسافات الأفقية
- استخدم دائماً `.r` لنصف القطر (borderRadius)
- استخدم دائماً `.sp` لأحجام الخطوط
- مثال: `SizedBox(height: 16.h)`, `width: 100.w`, `borderRadius: 24.r`, `fontSize: 18.sp`

### 3. التصميم العربي (RTL):
- الصفحة يجب أن تكون من اليمين لليسار (RTL)
- استخدم `Directionality(textDirection: TextDirection.rtl, child: ...)` في الـ Scaffold أو الـ body
- استخدم `EdgeInsetsDirectional` بدلاً من `EdgeInsets` عند الحاجة
- استخدم `PositionedDirectional` بدلاً من `Positioned` عند الحاجة
- في الـ Row، العناصر تبدأ من اليمين (start = right في RTL)
- استخدم `crossAxisAlignment: CrossAxisAlignment.end` للنصوص العربية

### 4. تنظيم الأيقونات:
- ضع الأيقونات في مجلد مخصص للصفحة داخل `assets/svg/client/[feature_name]/`
- مثال: إذا كانت الصفحة في `lib/features/client/orders/`، ضع الأيقونات في `assets/svg/client/orders/`
- استخدم مسارات كاملة مثل: `'assets/svg/client/[feature_name]/icon_name.svg'`
- أضف المسار الجديد في `pubspec.yaml` تحت قسم `assets` إذا لزم الأمر

### 5. أنماط النصوص:
- استخدم extension methods من `app_text_styles.dart`:
  - `TextStyle().textColorLight()` للخطوط الخفيفة (FontWeight.w300)
  - `TextStyle().textColorNormal()` للخطوط العادية (FontWeight.w400)
  - `TextStyle().textColorMedium()` للخطوط المتوسطة (FontWeight.w500)
  - `TextStyle().textColorSemiBold()` للخطوط شبه الغليظة (FontWeight.w600)
  - `TextStyle().textColorBold()` للخطوط الغليظة (FontWeight.w700)
  - `TextStyle().textColorBlack()` للخطوط السوداء (FontWeight.w900)
- دائماً حدد `fontSize` و `color` كمعاملات
- مثال: `TextStyle().textColorBold(fontSize: 18.sp, color: Color(0xFF101828))`

### 6. الألوان:
- استخدم الألوان الثابتة مثل `Color(0xFF101828)` بدلاً من `Colors.black`
- استخدم `Colors.white` و `Colors.transparent` عند الحاجة
- استخدم `.withOpacity()` لتعديل الشفافية

### 7. الصور:
- استخدم `CachedNetworkImage` من `cached_network_image` للصور من الإنترنت
- استخدم `ClipRRect` مع `BorderRadius` لتقريب الصور
- استخدم `fit: BoxFit.cover` للصور الخلفية

### 8. البنية العامة للصفحة:
```dart
class [PageName]Screen extends StatelessWidget {
  const [PageName]Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(context),
            
            // Content Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sections here
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Private methods for building sections
  Widget _buildHeaderSection(BuildContext context) { ... }
  Widget _buildSection1() { ... }
  // etc.
}
```

### 9. الأزرار والأيقونات:
- استخدم `CustomIconButtonApp` للأزرار الدائرية أو المربعة الصغيرة
- استخدم `CustomButtonApp` للأزرار الكبيرة
- استخدم `SvgIcon` داخل الأزرار لعرض الأيقونات
- مثال:
```dart
CustomIconButtonApp(
  width: 40.w,
  height: 40.h,
  radius: 100.r,
  color: Color(0xB37F22FE),
  onTap: () {
    Navigator.pop(context);
  },
  childWidget: SvgIcon(
    iconName: 'assets/svg/client/[feature]/icon.svg',
    width: 20.w,
    height: 20.h,
    color: Colors.white,
  ),
)
```

### 10. الـ Stack والـ Positioned:
- استخدم `Stack` مع `clipBehavior: Clip.none` عند الحاجة لعناصر متداخلة
- استخدم `PositionedDirectional` بدلاً من `Positioned` للـ RTL
- استخدم `bottom`, `top`, `start`, `end` للوضعية

### 11. الـ Container والـ Decoration:
- استخدم `BoxDecoration` مع `borderRadius`, `color`, `border`, `boxShadow`
- استخدم `BorderRadius.circular(24.r)` أو `BorderRadius.only()` حسب الحاجة
- استخدم `BoxShadow` للتأثيرات الظلية

### 12. الـ ListView:
- استخدم `ListView` مع `scrollDirection: Axis.horizontal` للقوائم الأفقية
- استخدم `SizedBox` مع `height` محدد للقوائم الأفقية
- استخدم `padding` مع `EdgeInsets.symmetric(horizontal: 24.w)`

### 13. الـ Spacing:
- استخدم `SizedBox(height: X.h)` أو `SizedBox(width: X.w)` للمسافات
- استخدم `Spacer()` عند الحاجة
- استخدم `Padding` مع `EdgeInsets` أو `EdgeInsetsDirectional`

### 14. الـ Imports المطلوبة:
```dart
import 'package:avvento/core/theme/app_text_styles.dart';
import 'package:avvento/core/widgets/reusable/svg_icon.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_button_app.dart';
import 'package:avvento/core/widgets/reusable/custom_button_app/custom_icon_button_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
```

---

## معلومات إضافية عن الصفحة المطلوبة:

[ضع هنا وصف الصفحة التي تريد إنشاءها، بما في ذلك:
- اسم الصفحة
- الأقسام المطلوبة
- الأيقونات المطلوبة
- البيانات التي ستُعرض
- أي تفاصيل تصميمية خاصة]

---

## ملاحظات مهمة:

1. **دائماً استخدم `.h`, `.w`, `.r`, `.sp`** - لا تستخدم قيماً ثابتة بدون هذه الامتدادات
2. **التصميم RTL** - تأكد من أن كل شيء يبدأ من اليمين
3. **تنظيم الكود** - قسم الكود إلى methods خاصة (`_build...`) لكل قسم
4. **الأيقونات** - ضعها في مجلد مخصص للصفحة
5. **الألوان** - استخدم hex colors مثل `Color(0xFF101828)`
6. **النصوص** - استخدم extension methods من `app_text_styles.dart`
7. **الصور** - استخدم `CachedNetworkImage` مع `ClipRRect`
8. **الأزرار** - استخدم `CustomButtonApp` و `CustomIconButtonApp`
9. **المسافات** - استخدم `SizedBox` و `Padding` بشكل متسق
10. **الـ Stack** - استخدم `PositionedDirectional` للعناصر المطلقة في RTL

---

## مثال على استخدام البرومبت:

```
أريد إنشاء صفحة تفاصيل الطلب (Order Details Screen) في `lib/features/client/orders/pages/order_details_screen.dart`

الأقسام المطلوبة:
1. Header Section: صورة خلفية مع زر الرجوع واسم المطعم
2. Order Info Section: معلومات الطلب (رقم الطلب، التاريخ، الحالة)
3. Items Section: قائمة الأصناف المطلوبة
4. Delivery Info Section: معلومات التوصيل (العنوان، الوقت المتوقع)
5. Payment Section: معلومات الدفع (المجموع، طريقة الدفع)

الأيقونات المطلوبة (ضعها في `assets/svg/client/orders/`):
- back_icon.svg
- order_icon.svg
- location_icon.svg
- payment_icon.svg
- status_icon.svg
```

---

استخدم هذا البرومبت كقالب واملأ المعلومات الخاصة بالصفحة التي تريد إنشاءها.
