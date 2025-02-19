import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatRequestStatus {
  pending,
  accepted,
  rejected,
}

class ChatRequestModel {
  final String requestId;
  final String senderId;
  final String receiverId;
  final ChatRequestStatus status;
  final DateTime createdAt;

  ChatRequestModel({
    required this.requestId,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatRequestModel.fromMap(Map<String, dynamic> map) {
    return ChatRequestModel(
      requestId: map['requestId'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      status: ChatRequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ChatRequestStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
