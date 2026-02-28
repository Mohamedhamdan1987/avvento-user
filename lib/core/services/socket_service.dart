import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';
import '../constants/app_constants.dart';
import '../enums/order_status.dart';
import 'notification_service.dart';

class SocketService extends GetxService {
  late IO.Socket? _notificationSocket;
  final box = GetStorage();

  final RxBool isConnected = false.obs;
  final RxList<Map<String, dynamic>> availableOrders = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;

  String? userRole;
  String? userId;

  Function(List<dynamic> orders)? onAvailableOrdersReceived;
  Function(Map<String, dynamic> data)? onOrderTakenForController;
  Function(Map<String, dynamic> data)? onOrderStatusUpdateForController;
  Function(Map<String, dynamic> data)? onNewOrderAvailableForController;

  @override
  void onInit() {
    super.onInit();
    AppLogger.debug('🚀 SocketService initialized', 'SocketService');
    _loadUserData();
  }

  void _loadUserData() {
    final userData = box.read<Map<String, dynamic>>(AppConstants.userKey);
    if (userData != null) {
      userRole = userData['role'];
      userId = userData['id'];
      AppLogger.debug('👤 User data loaded: role=$userRole, userId=$userId', 'SocketService');
    } else {
      AppLogger.debug('⚠️ No user data found in storage', 'SocketService');
    }
  }

  /// Connect to notifications namespace with provided token
  void connectWithToken(String token) {
    if (isConnected.value && _notificationSocket != null && _notificationSocket!.connected) {
      AppLogger.debug('🔌 Socket already connected, skipping redundant connection', 'SocketService');
      return;
    }

    _loadUserData(); // Ensure we have the latest user role and ID before connecting

    AppLogger.debug('🔌 Connecting socket with provided token...', 'SocketService');
    AppLogger.debug('Token: ${token.substring(0, token.length > 30 ? 30 : token.length)}...', 'SocketService');

    final socketUrl = _buildSocketNamespaceUrl('/notifications');

    _notificationSocket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['polling', 'websocket'])
          .setAuth({'token': token})
          .setQuery({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .build(),
    );

    AppLogger.debug('📡 Socket instance created for URL: $socketUrl', 'SocketService');
    // Note: Socket ID will be null until connection is established
    _setupNotificationHandlers();
  }

  String _buildSocketNamespaceUrl(String namespace) {
    final cleanNamespace = namespace.startsWith('/') ? namespace : '/$namespace';
    final uri = Uri.parse(AppConstants.baseUrl.trim());
    final scheme = uri.scheme;
    final host = uri.host;
    final hasRealPort = uri.hasPort && uri.port > 0;
    final port = hasRealPort ? uri.port : (scheme == 'https' ? 443 : 80);
    return '$scheme://$host:$port$cleanNamespace';
  }

  /// Connect to notifications namespace for real-time order updates
  void connectToNotifications() {
    final token = box.read(AppConstants.tokenKey);
    
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

    AppLogger.debug('⚙️ Setting up socket notification handlers for role: $userRole', 'SocketService');

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
      
      // If it's an order notification, show it with progress
      if (notification['type'] == 'order' && notification['orderStatus'] != null) {
        final status = OrderStatus.fromString(notification['orderStatus']);
        _showOrderStatusNotification(
          orderId: notification['orderId'] ?? '',
          status: status,
          title: notification['title'],
          body: notification['body'],
        );
      }
    });

    // ============ DELIVERY DRIVER ONLY ============
    if (userRole == 'delivery') {
      _notificationSocket!.on('available-orders', (data) {
        AppLogger.debug('📦 Available orders received via socket', 'SocketService');
        AppLogger.debug('📦 Orders data: $data', 'SocketService');
        final ordersList = data is List
            ? data
            : (data is Map && data.containsKey('orders'))
                ? data['orders'] as List
                : [];
        AppLogger.debug('📦 Parsed orders list (${ordersList.length} items): $ordersList', 'SocketService');
        onAvailableOrdersReceived?.call(ordersList);


      });

      // 🟢 NEW ORDER AVAILABLE - Order created and waiting for driver
      _notificationSocket!.on('new-order-available', (data) {
        final orderData = Map<String, dynamic>.from(data);
        AppLogger.debug('📦 New order available: $orderData', 'SocketService');
        
        final exists = availableOrders.any((o) => o['orderId'] == orderData['orderId']);
        if (!exists) {
          availableOrders.add(orderData);
          AppLogger.debug('✅ Order added to available list', 'SocketService');
        }
        onNewOrderAvailableForController?.call(orderData);
      });

      // 🔴 ORDER TAKEN - Another driver took this order
      _notificationSocket!.on('order-taken', (data) {
        final orderData = Map<String, dynamic>.from(data);
        AppLogger.debug('🚚 Order taken: $orderData', 'SocketService');

        availableOrders.removeWhere(
          (order) => order['orderId'] == orderData['orderId'],
        );
        AppLogger.debug(
          '✅ Order ${orderData['orderId']} removed (taken by driver)',
          'SocketService',
        );
        onOrderTakenForController?.call(orderData);
      });

      // 🟡 ORDER STATUS UPDATE - Order cancelled or status changed
      _notificationSocket!.on('order-status-update', (data) {
        final updateData = Map<String, dynamic>.from(data);
        AppLogger.debug('🔄 Order status update: $updateData', 'SocketService');

        if (updateData['status'] == 'cancelled') {
          availableOrders.removeWhere(
            (order) => order['orderId'] == updateData['orderId'],
          );
          AppLogger.debug(
            '✅ Order ${updateData['orderId']} removed (cancelled)',
            'SocketService',
          );
          
          _showOrderStatusNotification(
            orderId: updateData['orderId'],
            status: OrderStatus.cancelled,
          );
        } else {
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
          
          final status = OrderStatus.fromString(updateData['status']);
          _showOrderStatusNotification(
            orderId: updateData['orderId'],
            status: status,
          );
        }
        onOrderStatusUpdateForController?.call(updateData);
      });
    }

    // ============ CLIENT ONLY ============
    if (userRole == 'client') {
      // 🟡 ORDER STATUS UPDATE - Order status changed for client's order
      _notificationSocket!.on('order-status-update', (data) {
        final updateData = Map<String, dynamic>.from(data);
        AppLogger.debug('🔄 Client order status update: $updateData', 'SocketService');

        // Show notification with progress for status update
        final status = OrderStatus.fromString(updateData['status']);
        _showOrderStatusNotification(
          orderId: updateData['orderId'],
          status: status,
        );
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

  /// Show order status notification with progress bar
  void _showOrderStatusNotification({
    required String orderId,
    required OrderStatus status,
    String? title,
    String? body,
  }) {
    // Generate default title and body if not provided
    final notificationTitle = title ?? 'تحديث الطلب #${orderId.substring(0, 8)}';
    final notificationBody = body ?? 'حالة الطلب: ${status.label}';
    
    NotificationService.instance.showOrderNotification(
      orderId: orderId,
      title: notificationTitle,
      body: notificationBody,
      status: status,
    );
  }

  void emitGetAvailableOrders() {
    if (_notificationSocket != null && _notificationSocket!.connected) {
      _notificationSocket!.emit('get-available-orders');
      AppLogger.debug('📤 Emitted get-available-orders', 'SocketService');
    } else {
      AppLogger.debug('⚠️ Socket not connected, waiting to emit get-available-orders', 'SocketService');
      _notificationSocket?.once('connect', (_) {
        _notificationSocket!.emit('get-available-orders');
        AppLogger.debug('📤 Emitted get-available-orders (after connect)', 'SocketService');
      });
    }
  }

  void clearControllerCallbacks() {
    onAvailableOrdersReceived = null;
    onOrderTakenForController = null;
    onOrderStatusUpdateForController = null;
    onNewOrderAvailableForController = null;
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
    final newToken = box.read(AppConstants.tokenKey);
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
