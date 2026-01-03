import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../auth/models/user_model.dart';
import '../../domain/repositories/support_repository.dart';
import '../../domain/entities/support_conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

class SupportController extends GetxController {
  final SupportRepository supportRepository;
  final GetStorage _storage = GetStorage();

  SupportController({required this.supportRepository});

  // Observable state
  final RxList<MessageEntity> messages = <MessageEntity>[].obs;
  final Rx<SupportConversationEntity?> currentConversation = Rx<SupportConversationEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  int currentPage = 1;
  final int pageSize = 50;
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  void onInit() {
    super.onInit();
    initializeConversation();
  }

  Future<void> initializeConversation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get user data
      final userData = _storage.read<Map<String, dynamic>>(AppConstants.userKey);
      if (userData == null) {
        errorMessage.value = 'المستخدم غير مسجل دخول';
        return;
      }

      // Try to get existing conversations
      final conversations = await supportRepository.getUserConversations();

      // Find open conversation or create new one
      SupportConversationEntity? openConversation;
      if (conversations.isNotEmpty) {
        openConversation = conversations.firstWhereOrNull(
          (conv) => conv.status == ConversationStatus.open,
        );
      }

      if (openConversation != null) {
        currentConversation.value = openConversation;
        await loadMessages(openConversation.id);
      } else {
        // Create new conversation with admin (works for both users and restaurants now)
        await createConversationWithAdmin();
      }
    } catch (e) {
      errorMessage.value = e.toString();
      showSnackBar(
        title: 'خطأ',
        message: 'فشل تحميل المحادثة: ${e.toString()}',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createConversationWithAdmin({String? subject}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final conversation = await supportRepository.createConversationWithAdmin(
        subject: subject ?? 'طلب دعم من المطعم',
      );

      currentConversation.value = conversation;
      await loadMessages(conversation.id);
    } catch (e) {
      errorMessage.value = e.toString();
      showSnackBar(
        title: 'خطأ',
        message: 'فشل إنشاء المحادثة: ${e.toString()}',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages(String conversationId, {bool refresh = false}) async {
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

      final response = await supportRepository.getConversationMessages(
        conversationId: conversationId,
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
      await supportRepository.markMessagesAsRead(conversationId);
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

    if (conversation.status == ConversationStatus.closed) {
      showSnackBar(
        title: 'خطأ',
        message: 'المحادثة مغلقة',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final message = await supportRepository.sendMessage(
        conversationId: conversation.id,
        content: text.trim(),
        type: 'text',
      );

      // Add message to list
      messages.add(message);

      // Update conversation
      final updatedConversation = await supportRepository.getConversationById(conversation.id);
      currentConversation.value = updatedConversation;
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
    final conversation = currentConversation.value;
    if (conversation != null) {
      await loadMessages(conversation.id, refresh: true);
    }
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
    final conversation = currentConversation.value;
    if (conversation == null) return false;

    final userData = _storage.read<Map<String, dynamic>>(AppConstants.userKey);
    if (userData == null) return false;

    final user = UserModel.fromJson(userData);
    final currentUserId = user.id;

    // Message is from support if sender is not the current user
    return message.senderId != currentUserId;
  }
}

