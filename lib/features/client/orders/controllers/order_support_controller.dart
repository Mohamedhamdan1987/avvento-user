import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/support_socket_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../auth/models/user_model.dart';
import '../../../support/domain/repositories/support_repository.dart';
import '../../../support/domain/entities/support_conversation_entity.dart';
import '../../../support/domain/entities/message_entity.dart';
import '../../../support/data/models/message_model.dart';

class OrderSupportController extends GetxController {
  final SupportRepository supportRepository;
  final String orderId;

  OrderSupportController({
    required this.supportRepository,
    required this.orderId,
  });

  final GetStorage _storage = GetStorage();
  late final SupportSocketService _socketService;

  // Observable state
  final RxList<MessageEntity> messages = <MessageEntity>[].obs;
  final Rx<SupportConversationEntity?> currentConversation =
      Rx<SupportConversationEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isConversationClosed = false.obs;

  // Pagination
  int currentPage = 1;
  final int pageSize = 50;
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  void onInit() {
    super.onInit();
    _socketService = SupportSocketService();
    _setupSocketCallbacks();
    _socketService.connect();
    loadOrderChat();
  }

  @override
  void onClose() {
    final conversation = currentConversation.value;
    if (conversation != null) {
      _socketService.leaveConversation(conversation.id);
    }
    _socketService.disconnect();
    super.onClose();
  }

  void _setupSocketCallbacks() {
    _socketService.onNewMessage = _handleNewMessage;
    _socketService.onConversationUpdated = _handleConversationUpdated;
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      cprint("Received socket message: $data",);
      final message = MessageModel.fromJson(data);

      // Avoid adding duplicate messages
      final exists = messages.any((m) => m.id == message.id);
      if (!exists) {
        messages.add(message);
        AppLogger.debug(
          'Real-time message added: ${message.content}',
          'OrderSupportCtrl',
        );
      }
    } catch (e) {
      AppLogger.warning(
        'Failed to parse socket message: $e',
        'OrderSupportCtrl',
      );
    }
  }

  void _handleConversationUpdated(Map<String, dynamic> data) {
    try {
      final status = data['status']?.toString() ?? '';
      AppLogger.debug(
        'Conversation status updated: $status',
        'OrderSupportCtrl',
      );

      if (status == 'closed') {
        isConversationClosed.value = true;

        // Add system close message if present in lastMessage
        if (data['lastMessage'] is Map) {
          final lastMsg = MessageModel.fromJson(
            Map<String, dynamic>.from(data['lastMessage']),
          );
          final exists = messages.any((m) => m.id == lastMsg.id);
          if (!exists) {
            messages.add(lastMsg);
          }
        }
      } else if (status == 'open') {
        isConversationClosed.value = false;
      }
    } catch (e) {
      AppLogger.warning(
        'Failed to handle conversation update: $e',
        'OrderSupportCtrl',
      );
    }
  }

  Future<void> loadOrderChat() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final conversation = await supportRepository.getOrderChat(orderId);
      currentConversation.value = conversation;
      isConversationClosed.value =
          conversation.status == ConversationStatus.closed;

      // Join the conversation room via socket
      _socketService.joinConversation(conversation.id);

      await loadMessages(refresh: true);
    } catch (e) {
      errorMessage.value = e.toString();
      showSnackBar(
        title: 'خطأ',
        message: 'فشل تحميل محادثة الطلب: ${e.toString()}',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage = 1;
        hasMore = true;
        messages.clear();
        isLoadingMessages.value = true;
      }

      if (!hasMore || isLoadingMore) return;

      isLoadingMore = true;
      errorMessage.value = '';

      final response = await supportRepository.getOrderChatMessages(
        orderId: orderId,
        page: currentPage,
        limit: pageSize,
      );

      if (refresh) {
        messages.value = response.messages.reversed.toList();
      } else {
        messages.insertAll(0, response.messages.reversed.toList());
      }

      hasMore = currentPage * pageSize < response.total;
      currentPage++;

      // Mark messages as read
      final conversation = currentConversation.value;
      if (conversation != null) {
        await supportRepository.markMessagesAsRead(conversation.id);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingMore = false;
      isLoadingMessages.value = false;
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final conversation = currentConversation.value;
    if (conversation == null) {
      showSnackBar(
        title: 'خطأ',
        message: 'لا توجد محادثة نشطة',
        isError: true,
      );
      return;
    }

    if (isConversationClosed.value) {
      showSnackBar(
        title: 'تنبيه',
        message: 'المحادثة مغلقة - انتهى الطلب',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final message = await supportRepository.sendOrderChatMessage(
        conversationId: conversation.id,
        content: text.trim(),
        type: 'text',
      );

      // Add the sent message locally (socket will also broadcast it,
      // but we add it here for instant UI feedback and deduplicate later)
      final exists = messages.any((m) => m.id == message.id);
      if (!exists) {
        messages.add(message);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      showSnackBar(
        title: 'خطأ',
        message: 'فشل إرسال الرسالة: ${e.toString()}',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMessages() async {
    await loadMessages(refresh: true);
  }

  String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  bool isMessageFromSupport(MessageEntity message) {
    final userData =
        _storage.read<Map<String, dynamic>>(AppConstants.userKey);
    if (userData == null) return false;

    final user = UserModel.fromJson(userData);
    final currentUserId = user.id;

    return message.senderId != currentUserId;
  }

  String get orderShortId {
    if (orderId.length >= 6) {
      return orderId.substring(orderId.length - 6).toUpperCase();
    }
    return orderId.toUpperCase();
  }
}
