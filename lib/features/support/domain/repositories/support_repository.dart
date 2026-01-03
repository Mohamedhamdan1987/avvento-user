import '../entities/support_conversation_entity.dart';
import '../entities/message_entity.dart';

class MessagesResponse {
  final List<MessageEntity> messages;
  final int total;

  MessagesResponse({
    required this.messages,
    required this.total,
  });
}

abstract class SupportRepository {
  Future<SupportConversationEntity> createConversation({
    String? participantId,
    String? subject,
  });
  Future<SupportConversationEntity> createConversationWithAdmin({
    String? subject,
  });
  Future<List<SupportConversationEntity>> getUserConversations();
  Future<SupportConversationEntity> getConversationById(String id);
  Future<SupportConversationEntity> updateConversation({
    required String id,
    String? status,
    String? subject,
  });
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String content,
    String? type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  });
  Future<MessagesResponse> getConversationMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  });
  Future<void> markMessagesAsRead(String conversationId);
}

