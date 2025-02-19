import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final bool isGroup;
  final String? groupName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, bool> readStatus;

  ChatModel({
    required this.id,
    required this.participants,
    required this.isGroup,
    this.groupName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.readStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'isGroup': isGroup,
      'groupName': groupName,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'readStatus': readStatus,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as String,
      participants: List<String>.from(map['participants']),
      isGroup: map['isGroup'] as bool,
      groupName: map['groupName'] as String?,
      lastMessage: map['lastMessage'] as String,
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      readStatus: Map<String, bool>.from(map['readStatus']),
    );
  }
}
