import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/api_exception.dart';
import '../models/support_conversation_model.dart';
import '../models/message_model.dart';

class MessagesResponse {
  final List<MessageModel> messages;
  final int total;

  MessagesResponse({
    required this.messages,
    required this.total,
  });
}

abstract class SupportRemoteDataSource {
  Future<SupportConversationModel> createConversation({
    String? participantId,
    String? subject,
  });
  Future<SupportConversationModel> createConversationWithAdmin({
    String? subject,
  });
  Future<List<SupportConversationModel>> getUserConversations();
  Future<SupportConversationModel> getConversationById(String id);
  Future<SupportConversationModel> updateConversation({
    required String id,
    String? status,
    String? subject,
  });
  Future<MessageModel> sendMessage({
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

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final DioClient dioClient;

  SupportRemoteDataSourceImpl(this.dioClient);

  @override
  Future<SupportConversationModel> createConversation({
    String? participantId,
    String? subject,
  }) async {
    try {
      final response = await dioClient.post(
        'support/conversations',
        data: {
          if (participantId != null) 'participantId': participantId,
          if (subject != null) 'subject': subject,
        },
      );
      return SupportConversationModel.fromJson(response.data);
    } on DioException catch (e) {
      final failure = ApiException.handleException(e);
      throw Exception(failure.message);
    } catch (e) {
      throw Exception('Failed to create conversation: ${e.toString()}');
    }
  }

  @override
  Future<SupportConversationModel> createConversationWithAdmin({
    String? subject,
  }) async {
    try {
      final response = await dioClient.post(
        'support/conversations/with-admin',
        data: {
          if (subject != null) 'subject': subject,
        },
      );
      return SupportConversationModel.fromJson(response.data);
    } on DioException catch (e) {
      final failure = ApiException.handleException(e);
      throw Exception(failure.message);
    } catch (e) {
      throw Exception('Failed to create conversation with admin: ${e.toString()}');
    }
  }

  @override
  Future<List<SupportConversationModel>> getUserConversations() async {
    try {
      final response = await dioClient.get('support/conversations');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => SupportConversationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      final failure = ApiException.handleException(e);
      throw Exception(failure.message);
    } catch (e) {
      throw Exception('Failed to get conversations: ${e.toString()}');
    }
  }

  @override
  Future<SupportConversationModel> getConversationById(String id) async {
    try {
      final response = await dioClient.get('support/conversations/$id');
      return SupportConversationModel.fromJson(response.data);
    } on DioException catch (e) {
      final failure = ApiException.handleException(e);
      throw Exception(failure.message);
    } catch (e) {
      throw Exception('Failed to get conversation: ${e.toString()}');
    }
  }

  @override
  Future<SupportConversationModel> updateConversation({
    required String id,
    String? status,
    String? subject,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;
      if (subject != null) data['subject'] = subject;

      final response = await dioClient.patch(
        'support/conversations/$id',
        data: data,
      );
      return SupportConversationModel.fromJson(response.data);
    } on DioException catch (e) {
      final failure = ApiException.handleException(e);
      throw Exception(failure.message);
    } catch (e) {
      throw Exception('Failed to update conversation: ${e.toString()}');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    String? type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) async {
    try {
      final response = await dioClient.post(
        'support/messages',
        data: {
          'conversationId': conversationId,
          'content': content,
          if (type != null) 'type': type,
          if (fileUrl != null) 'fileUrl': fileUrl,
          if (fileName != null) 'fileName': fileName,
          if (fileSize != null) 'fileSize': fileSize,
        },
      );
      return MessageModel.fromJson(response.data);
    } on DioException catch (e) {
      final failure = ApiException.handleException(e);
      throw Exception(failure.message);
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  @override
  Future<MessagesResponse> getConversationMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await dioClient.get(
        'support/conversations/$conversationId/messages',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data;
      List<MessageModel> messages = [];
      int total = 0;

      if (data is Map<String, dynamic>) {
        if (data['messages'] is List) {
          messages = (data['messages'] as List)
              .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        total = data['total'] ?? 0;
      } else if (data is List) {
        messages = data
            .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
            .toList();
        total = messages.length;
      }

      return MessagesResponse(messages: messages, total: total);
    } on DioException catch (e) {
      final failure = ApiException.handleException(e);
      throw Exception(failure.message);
    } catch (e) {
      throw Exception('Failed to get messages: ${e.toString()}');
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await dioClient.post('support/conversations/$conversationId/read');
    } on DioException catch (e) {
      final failure = ApiException.handleException(e);
      throw Exception(failure.message);
    } catch (e) {
      throw Exception('Failed to mark messages as read: ${e.toString()}');
    }
  }
}

