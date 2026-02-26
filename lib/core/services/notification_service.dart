import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/dio_client.dart';
import '../enums/order_status.dart';
import '../constants/app_colors.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        log("Notification tapped: ${details.payload}");
      },
    );

    // Create Notification Channel for Android - General
    const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    // Create Notification Channel for Orders with brand styling
    final AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      'order_updates_channel',
      'تحديثات الطلبات',
      description: 'إشعارات تحديثات حالة الطلبات',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      ledColor: AppColors.purple,
      enableLights: true,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlugin?.createNotificationChannel(generalChannel);
    await androidPlugin?.createNotificationChannel(orderChannel);

    // Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        // Check if this is an order notification and extract status
        final orderStatus = message.data['orderStatus'] as String?;
        final isOrderNotification = orderStatus != null;
        
        // Calculate progress for order notifications
        int progress = 0;
        int maxProgress = 100;
        
        if (isOrderNotification && orderStatus.isNotEmpty) {
          final status = OrderStatus.fromString(orderStatus);
          final progressData = _getOrderProgress(status);
          progress = progressData['current']!;
          maxProgress = progressData['max']!;
        }

        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              isOrderNotification ? orderChannel.id : generalChannel.id,
              isOrderNotification ? orderChannel.name : generalChannel.name,
              channelDescription: isOrderNotification 
                  ? orderChannel.description 
                  : generalChannel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@drawable/ic_notification',
              // Brand purple color - always purple for consistency
              color: AppColors.purple,
              colorized: true,
              ledColor: AppColors.purple,
              ledOnMs: 1000,
              ledOffMs: 500,
              enableLights: true,
              // Add progress bar for order notifications - purple colored
              showProgress: isOrderNotification,
              maxProgress: maxProgress,
              progress: progress,
              indeterminate: false,
              ongoing: isOrderNotification && progress < maxProgress,
              autoCancel: !isOrderNotification || progress >= maxProgress,
              // Category for progress notifications
              category: isOrderNotification 
                  ? AndroidNotificationCategory.progress 
                  : null,
              // Style
              styleInformation: isOrderNotification 
                  ? BigTextStyleInformation(
                      notification.body ?? '',
                      contentTitle: '<b>${notification.title}</b>',
                      htmlFormatContentTitle: true,
                      summaryText: 'Avvento',
                    )
                  : null,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    // Handle Token Refresh
    _fcm.onTokenRefresh.listen((token) {
      updateTokenOnServer(token);
    });
  }

  Future<void> updateTokenOnServer([String? token]) async {
    try {
      final fcmToken = token ?? await _fcm.getToken();
      if (fcmToken != null) {
        log('FCM Token: $fcmToken');
        await DioClient.instance.patch(
          'auth/fcm-token',
          data: {'fcmToken': fcmToken},
        );
      }
    } catch (e) {
      log('Error updating FCM token: $e');
    }
  }

  /// Calculate order progress based on status
  /// Returns a map with 'current' and 'max' progress values
  Map<String, int> _getOrderProgress(OrderStatus status) {
    // Total steps (excluding cancelled)
    const int totalSteps = 7;
    
    int currentStep;
    switch (status) {
      case OrderStatus.deliveryTake:
        currentStep = 1;
        break;
      case OrderStatus.pending:
        currentStep = 2;
        break;
      case OrderStatus.preparing:
        currentStep = 3;
        break;
      case OrderStatus.deliveryReceived:
        currentStep = 4;
        break;
      case OrderStatus.onTheWay:
        currentStep = 5;
        break;
      case OrderStatus.awaitingDelivery:
        currentStep = 6;
        break;
      case OrderStatus.delivered:
        currentStep = 7;
        break;
      case OrderStatus.cancelled:
        currentStep = 0;
        break;
    }
    
    // Convert to percentage (0-100)
    final progressPercentage = ((currentStep / totalSteps) * 100).round();
    
    return {
      'current': progressPercentage,
      'max': 100,
    };
  }
  
  /// Show a custom order notification with progress
  Future<void> showOrderNotification({
    required String orderId,
    required String title,
    required String body,
    required OrderStatus status,
  }) async {
    final progressData = _getOrderProgress(status);
    final progress = progressData['current']!;
    final maxProgress = progressData['max']!;
    
    // Always use purple for progress bar - brand identity
    const Color progressColor = AppColors.purple;
    
    await _localNotifications.show(
      orderId.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'order_updates_channel',
          'تحديثات الطلبات',
          channelDescription: 'إشعارات تحديثات حالة الطلبات',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          // Brand purple color for progress bar
          color: progressColor,
          colorized: true,
          // LED purple light
          ledColor: progressColor,
          ledOnMs: 1000,
          ledOffMs: 500,
          enableLights: true,
          // Progress bar - purple colored
          showProgress: true,
          maxProgress: maxProgress,
          progress: progress,
          indeterminate: false,
          ongoing: progress < maxProgress && status != OrderStatus.cancelled,
          autoCancel: progress >= maxProgress || status == OrderStatus.cancelled,
          // Status label with emoji
          subText: '${_getStatusEmoji(status)} ${status.label} • $progress%',
          // Rich notification style
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: '<b>$title</b>',
            htmlFormatContentTitle: true,
            summaryText: 'Avvento • طلبك',
          ),
          // Ticker for accessibility
          ticker: '${status.label} - $title',
          // Category for better system handling
          category: AndroidNotificationCategory.progress,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: orderId,
    );
  }
  
  /// Get emoji based on order status
  String _getStatusEmoji(OrderStatus status) {
    switch (status) {
      case OrderStatus.deliveryTake:
        return '⏳';
      case OrderStatus.pending:
        return '✅';
      case OrderStatus.preparing:
        return '👨‍🍳';
      case OrderStatus.deliveryReceived:
        return '📦';
      case OrderStatus.onTheWay:
        return '🛵';
      case OrderStatus.awaitingDelivery:
        return '🏠';
      case OrderStatus.delivered:
        return '🎉';
      case OrderStatus.cancelled:
        return '❌';
    }
  }
  
  /// Test notification with progress bar - cycles through all order statuses
  Future<void> showTestOrderNotification([OrderStatus? status]) async {
    final testStatus = status ?? OrderStatus.preparing;
    final testOrderId = 'TEST-${DateTime.now().millisecondsSinceEpoch}';
    
    await showOrderNotification(
      orderId: testOrderId,
      title: '🧪 إشعار اختباري',
      body: 'هذا اختبار لشريط التقدم - ${testStatus.label}',
      status: testStatus,
    );
  }

  /// Test all order statuses sequentially with delay
  Future<void> showTestAllStatusesNotification() async {
    const testOrderId = 'TEST-ORDER-123';
    final statuses = [
      OrderStatus.deliveryTake,
      OrderStatus.pending,
      OrderStatus.preparing,
      OrderStatus.deliveryReceived,
      OrderStatus.onTheWay,
      OrderStatus.awaitingDelivery,
      OrderStatus.delivered,
    ];

    for (int i = 0; i < statuses.length; i++) {
      final status = statuses[i];
      await showOrderNotification(
        orderId: testOrderId,
        title: '🧪 اختبار التقدم (${i + 1}/${statuses.length})',
        body: status.label,
        status: status,
      );
      
      // Wait 3 seconds between each status
      if (i < statuses.length - 1) {
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("Handling a background message: ${message.messageId}");
}
