import 'package:avvento/features/auth/models/user_model.dart';

import 'message_entity.dart';

enum ConversationStatus {
  open,
  closed,
  pending,
}

class SupportConversationEntity {
  final String id;
  final String? adminId;
  final String? restaurantId;
  final String participantId;
  final ConversationStatus status;
  final String? lastMessageId;
  final DateTime? lastMessageAt;
  final int unreadCountSupport;
  final int unreadCountParticipant;
  final String? subject;
  final String supportType; // 'admin' or 'restaurant'
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Populated fields
  final UserModel? admin;
  final UserModel? restaurant;
  final UserModel? participant;
  final MessageEntity? lastMessage;

  SupportConversationEntity({
    required this.id,
    this.adminId,
    this.restaurantId,
    required this.participantId,
    required this.status,
    this.lastMessageId,
    this.lastMessageAt,
    required this.unreadCountSupport,
    required this.unreadCountParticipant,
    this.subject,
    required this.supportType,
    required this.createdAt,
    required this.updatedAt,
    this.admin,
    this.restaurant,
    this.participant,
    this.lastMessage,
  });
}

