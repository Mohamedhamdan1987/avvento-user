import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.type,
    required super.content,
    required super.isRead,
    super.readAt,
    required super.createdAt,
    required super.updatedAt,
    super.fileUrl,
    super.fileName,
    super.fileSize,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    String conversationId;
    if (json['conversation'] is Map) {
      conversationId = json['conversation']['_id'] ?? json['conversation']['id'] ?? '';
    } else {
      conversationId = json['conversation']?.toString() ?? '';
    }

    String senderId;
    if (json['sender'] is Map) {
      senderId = json['sender']['_id'] ?? json['sender']['id'] ?? '';
    } else {
      senderId = json['sender']?.toString() ?? '';
    }

    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: conversationId,
      senderId: senderId,
      type: _parseMessageType(json['type'] ?? 'text'),
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
    );
  }

  static MessageType _parseMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      case 'text':
      default:
        return MessageType.text;
    }
  }
}

