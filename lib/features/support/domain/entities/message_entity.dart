enum MessageType {
  text,
  image,
  file,
  system,
}

class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final MessageType type;
  final String content;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;

  MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.content,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    this.fileUrl,
    this.fileName,
    this.fileSize,
  });
}

