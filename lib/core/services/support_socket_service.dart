import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get_storage/get_storage.dart';
import '../utils/logger.dart';
import '../constants/app_constants.dart';

class SupportSocketService {
  IO.Socket? _socket;
  final GetStorage _box = GetStorage();

  bool isConnected = false;
  String? _currentConversationId;

  // Callbacks
  void Function(Map<String, dynamic>)? onNewMessage;
  void Function(Map<String, dynamic>)? onConversationUpdated;
  void Function(Map<String, dynamic>)? onNewConversation;

  void connect() {
    final token = _box.read<String>(AppConstants.tokenKey);
    if (token == null) {
      AppLogger.debug(
        'No token available for support socket',
        'SupportSocket',
      );
      return;
    }

    if (_socket != null && _socket!.connected) {
      AppLogger.debug(
        'Support socket already connected',
        'SupportSocket',
      );
      return;
    }

    String baseUrl = AppConstants.baseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    _socket = IO.io(
      '$baseUrl/support',
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .build(),
    );

    _setupHandlers();

    AppLogger.debug(
      'Support socket connecting to: $baseUrl/support',
      'SupportSocket',
    );
  }

  void _setupHandlers() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      AppLogger.debug(
        'Connected to support socket: ${_socket!.id}',
        'SupportSocket',
      );
      isConnected = true;

      // Re-join conversation if we had one (reconnection scenario)
      if (_currentConversationId != null) {
        joinConversation(_currentConversationId!);
      }
    });

    _socket!.onDisconnect((reason) {
      AppLogger.debug(
        'Disconnected from support socket: $reason',
        'SupportSocket',
      );
      isConnected = false;
    });

    _socket!.onConnectError((error) {
      AppLogger.warning(
        'Support socket connection error: $error',
        'SupportSocket',
      );
      isConnected = false;
    });

    // Listen for new messages
    _socket!.on('new-message', (data) {
      AppLogger.debug('New message received: $data', 'SupportSocket');
      if (data != null) {
        final message = Map<String, dynamic>.from(data);
        onNewMessage?.call(message);
      }
    });

    // Listen for conversation updates (status changes, closed, etc.)
    _socket!.on('conversation-updated', (data) {
      AppLogger.debug('Conversation updated: $data', 'SupportSocket');
      if (data != null) {
        final conversation = Map<String, dynamic>.from(data);
        onConversationUpdated?.call(conversation);
      }
    });

    // Listen for new conversations (sent to personal room)
    _socket!.on('new-conversation', (data) {
      AppLogger.debug('New conversation: $data', 'SupportSocket');
      if (data != null) {
        final conversation = Map<String, dynamic>.from(data);
        onNewConversation?.call(conversation);
      }
    });
  }

  void joinConversation(String conversationId) {
    _currentConversationId = conversationId;
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join-conversation', {'conversationId': conversationId});
      AppLogger.debug(
        'Joined conversation: $conversationId',
        'SupportSocket',
      );
    }
  }

  void leaveConversation(String conversationId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leave-conversation', {'conversationId': conversationId});
      AppLogger.debug(
        'Left conversation: $conversationId',
        'SupportSocket',
      );
    }
    _currentConversationId = null;
  }

  void disconnect() {
    if (_currentConversationId != null) {
      leaveConversation(_currentConversationId!);
    }
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected = false;
    AppLogger.debug('Support socket disconnected', 'SupportSocket');
  }
}
