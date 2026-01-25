import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../constants/app_constants.dart';

class SocketService extends GetxService {
  late IO.Socket? _notificationSocket;
  final box = GetStorage();

  final RxBool isConnected = false.obs;
  final RxList<Map<String, dynamic>> availableOrders = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;

  String? userRole;
  String? userId;

  @override
  void onInit() {
    super.onInit();
    AppLogger.debug('🚀 SocketService initialized', 'SocketService');
    _loadUserData();
  }

  void _loadUserData() {
    final userData = box.read('user');
    if (userData != null) {
      userRole = userData['role'];
      userId = userData['_id'];
      AppLogger.debug('👤 User data loaded: role=$userRole, userId=$userId', 'SocketService');
    } else {
      AppLogger.debug('⚠️ No user data found in storage', 'SocketService');
    }
  }

  /// Connect to notifications namespace with provided token
  void connectWithToken(String token) {
    AppLogger.debug('🔌 Connecting socket with provided token...', 'SocketService');
    AppLogger.debug('Token: ${token.substring(0, 30)}...', 'SocketService');

    _notificationSocket = IO.io(
      '${AppConstants.baseUrl}notifications',
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .setQuery({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .build(),
    );

    AppLogger.debug('📡 Socket instance created for URL: ${AppConstants.baseUrl}notifications', 'SocketService');
    AppLogger.debug('📡 Socket ID: ${_notificationSocket?.id}', 'SocketService');
    _setupNotificationHandlers();
  }

  /// Connect to notifications namespace for real-time order updates
  void connectToNotifications() {
    final token = box.read('token');
    
    AppLogger.debug('📋 Checking token availability...', 'SocketService');
    AppLogger.debug('Token exists: ${token != null}', 'SocketService');
    
    if (token == null) {
      AppLogger.debug('❌ No token available for socket connection (will retry on refresh)', 'SocketService');
      return;
    }
    
    connectWithToken(token);
  }

  void _setupNotificationHandlers() {
    if (_notificationSocket == null) return;

    AppLogger.debug('⚙️ Setting up socket notification handlers...', 'SocketService');

    // Connection handlers
    _notificationSocket!.onConnect((_) {
      AppLogger.debug(
        '✅ Connected to notifications socket: ${_notificationSocket!.id}',
        'SocketService',
      );
      isConnected.value = true;
    });

    _notificationSocket!.onDisconnect((reason) {
      AppLogger.debug('❌ Disconnected from notifications: $reason', 'SocketService');
      isConnected.value = false;
    });

    _notificationSocket!.onConnectError((error) {
      AppLogger.warning('🔴 Notifications connection error: $error', 'SocketService');
      isConnected.value = false;
    });

    // ============ ALL USERS ============
    _notificationSocket!.on('new-notification', (data) {
      final notification = Map<String, dynamic>.from(data);
      AppLogger.debug('📬 New notification: $notification', 'SocketService');
      notifications.insert(0, notification);
    });

    // ============ DELIVERY DRIVER ONLY ============
    if (userRole == 'delivery') {
      // 🟢 NEW ORDER AVAILABLE - Order created and waiting for driver
      _notificationSocket!.on('new-order-available', (data) {
        final orderData = Map<String, dynamic>.from(data);
        AppLogger.debug('📦 New order available: $orderData', 'SocketService');
        
        // Check if order already exists (prevent duplicates)
        final exists = availableOrders.any((o) => o['orderId'] == orderData['orderId']);
        if (!exists) {
          availableOrders.add(orderData);
          AppLogger.debug('✅ Order added to available list', 'SocketService');
        }
      });

      // 🔴 ORDER TAKEN - Another driver took this order
      _notificationSocket!.on('order-taken', (data) {
        final orderData = Map<String, dynamic>.from(data);
        AppLogger.debug('🚚 Order taken: $orderData', 'SocketService');

        // Remove order from available orders (another driver took it)
        availableOrders.removeWhere(
          (order) => order['orderId'] == orderData['orderId'],
        );
        AppLogger.debug(
          '✅ Order ${orderData['orderId']} removed (taken by driver)',
          'SocketService',
        );
      });

      // 🟡 ORDER STATUS UPDATE - Order cancelled or status changed
      _notificationSocket!.on('order-status-update', (data) {
        final updateData = Map<String, dynamic>.from(data);
        AppLogger.debug('🔄 Order status update: $updateData', 'SocketService');

        if (updateData['status'] == 'cancelled') {
          // Remove order if cancelled
          availableOrders.removeWhere(
            (order) => order['orderId'] == updateData['orderId'],
          );
          AppLogger.debug(
            '✅ Order ${updateData['orderId']} removed (cancelled)',
            'SocketService',
          );
        } else {
          // Update order status in list if exists
          final index = availableOrders.indexWhere(
            (order) => order['orderId'] == updateData['orderId'],
          );
          if (index != -1) {
            availableOrders[index]['status'] = updateData['status'];
            availableOrders.refresh();
            AppLogger.debug(
              '✅ Order ${updateData['orderId']} status updated to ${updateData['status']}',
              'SocketService',
            );
          }
        }
      });
    }

    // ============ ADMIN ONLY ============
    if (userRole == 'admin') {
      _notificationSocket!.on('admin-notification', (data) {
        final notification = Map<String, dynamic>.from(data);
        AppLogger.debug('👑 Admin notification: $notification', 'SocketService');
        notifications.insert(0, notification);
      });
    }
  }

  /// Disconnect all sockets
  void disconnect() {
    _notificationSocket?.disconnect();
    _notificationSocket?.dispose();
    isConnected.value = false;
    AppLogger.debug('Sockets disconnected', 'SocketService');
  }

  /// Refresh connection (useful when token expires)
  void refreshConnection() {
    disconnect();
    final newToken = box.read('token');
    if (newToken != null) {
      connectToNotifications();
    }
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
