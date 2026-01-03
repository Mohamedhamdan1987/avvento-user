import '../../../auth/models/user_model.dart';
import '../../domain/entities/support_conversation_entity.dart';
import 'message_model.dart';

class SupportConversationModel extends SupportConversationEntity {
  SupportConversationModel({
    required super.id,
    super.adminId,
    super.restaurantId,
    required super.participantId,
    required super.status,
    super.lastMessageId,
    super.lastMessageAt,
    required super.unreadCountSupport,
    required super.unreadCountParticipant,
    super.subject,
    required super.supportType,
    required super.createdAt,
    required super.updatedAt,
    super.admin,
    super.restaurant,
    super.participant,
    super.lastMessage,
  });

  factory SupportConversationModel.fromJson(Map<String, dynamic> json) {
    String? adminId;
    if (json['admin'] != null) {
      if (json['admin'] is Map) {
        adminId = json['admin']['_id'] ?? json['admin']['id'] ?? '';
      } else {
        adminId = json['admin']?.toString();
      }
    }

    String? restaurantId;
    if (json['restaurant'] != null) {
      if (json['restaurant'] is Map) {
        restaurantId = json['restaurant']['_id'] ?? json['restaurant']['id'] ?? '';
      } else {
        restaurantId = json['restaurant']?.toString();
      }
    }

    String participantId;
    if (json['participant'] is Map) {
      participantId = json['participant']['_id'] ?? json['participant']['id'] ?? '';
    } else {
      participantId = json['participant']?.toString() ?? '';
    }

    String? lastMessageId;
    if (json['lastMessage'] != null) {
      if (json['lastMessage'] is Map) {
        lastMessageId = json['lastMessage']['_id'] ?? json['lastMessage']['id'] ?? '';
      } else {
        lastMessageId = json['lastMessage']?.toString();
      }
    }

    return SupportConversationModel(
      id: json['_id'] ?? json['id'] ?? '',
      adminId: adminId,
      restaurantId: restaurantId,
      participantId: participantId,
      status: _parseConversationStatus(json['status'] ?? 'open'),
      lastMessageId: lastMessageId,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : null,
      unreadCountSupport: json['unreadCountSupport'] ?? 0,
      unreadCountParticipant: json['unreadCountParticipant'] ?? 0,
      subject: json['subject'],
      supportType: json['supportType'] ?? 'admin',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      admin: json['admin'] is Map ? UserModel.fromJson(json['admin']) : null,
      restaurant: json['restaurant'] is Map ? UserModel.fromJson(json['restaurant']) : null,
      participant: json['participant'] is Map ? UserModel.fromJson(json['participant']) : null,
      lastMessage: json['lastMessage'] is Map
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
    );
  }

  static ConversationStatus _parseConversationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'closed':
        return ConversationStatus.closed;
      case 'pending':
        return ConversationStatus.pending;
      case 'open':
      default:
        return ConversationStatus.open;
    }
  }
}

