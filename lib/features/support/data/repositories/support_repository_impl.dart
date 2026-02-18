import '../../domain/entities/support_conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_datasource.dart' as datasource;

class SupportRepositoryImpl implements SupportRepository {
  final datasource.SupportRemoteDataSource remoteDataSource;

  SupportRepositoryImpl(this.remoteDataSource);

  @override
  Future<SupportConversationEntity> createConversation({
    String? participantId,
    String? subject,
  }) async {
    return await remoteDataSource.createConversation(
      participantId: participantId,
      subject: subject,
    );
  }

  @override
  Future<SupportConversationEntity> createConversationWithAdmin({
    String? subject,
  }) async {
    return await remoteDataSource.createConversationWithAdmin(
      subject: subject,
    );
  }

  @override
  Future<List<SupportConversationEntity>> getUserConversations() async {
    return await remoteDataSource.getUserConversations();
  }

  @override
  Future<SupportConversationEntity> getConversationById(String id) async {
    return await remoteDataSource.getConversationById(id);
  }

  @override
  Future<SupportConversationEntity> updateConversation({
    required String id,
    String? status,
    String? subject,
  }) async {
    return await remoteDataSource.updateConversation(
      id: id,
      status: status,
      subject: subject,
    );
  }

  @override
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String content,
    String? type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) async {
    return await remoteDataSource.sendMessage(
      conversationId: conversationId,
      content: content,
      type: type,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  @override
  Future<MessagesResponse> getConversationMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    final remoteResponse = await remoteDataSource.getConversationMessages(
      conversationId: conversationId,
      page: page,
      limit: limit,
    );
    return MessagesResponse(
      messages: remoteResponse.messages,
      total: remoteResponse.total,
    );
  }

  @override
  Future<void> markMessagesAsRead(String conversationId) async {
    await remoteDataSource.markMessagesAsRead(conversationId);
  }

  @override
  Future<SupportConversationEntity> getOrderChat(String orderId) async {
    return await remoteDataSource.getOrderChat(orderId);
  }

  @override
  Future<MessagesResponse> getOrderChatMessages({
    required String orderId,
    int page = 1,
    int limit = 50,
  }) async {
    final remoteResponse = await remoteDataSource.getOrderChatMessages(
      orderId: orderId,
      page: page,
      limit: limit,
    );
    return MessagesResponse(
      messages: remoteResponse.messages,
      total: remoteResponse.total,
    );
  }

  @override
  Future<MessageEntity> sendOrderChatMessage({
    required String conversationId,
    required String content,
    String? type,
  }) async {
    return await remoteDataSource.sendOrderChatMessage(
      conversationId: conversationId,
      content: content,
      type: type,
    );
  }
}

