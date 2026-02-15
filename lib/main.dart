import 'package:avvento/core/utils/logger.dart';
import 'package:avvento/features/client/orders/widgets/floating_active_order_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notification_service.dart';
import 'core/utils/location_utils.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Notification Service
  await NotificationService.instance.initialize();

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize intl date formatting for Arabic
  await initializeDateFormatting('ar', null);

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize device location
  await LocationUtils.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (context, child) {
        final themeController = Get.put(ThemeController());
        final GetStorage _storage = GetStorage();
        final token = _storage.read<String>(AppConstants.tokenKey);
        cprint("token: $token");

        return GetMaterialApp(
          title: 'We Pay',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.theme,
          initialRoute: AppPages.getInitialRoute(),
          getPages: AppPages.routes,
          defaultTransition: Transition.fade,
          transitionDuration: const Duration(milliseconds: 300),
          locale: const Locale('ar'),
          fallbackLocale: const Locale('ar'),
          builder: (context, widget) {
            return Material(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Stack(
                  children: [
                    widget!,
                    const Positioned.fill(
                      child: FloatingActiveOrderBanner(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
