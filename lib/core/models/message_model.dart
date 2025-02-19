import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] as String,
      chatId: map['chatId'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}
