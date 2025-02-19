import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/chat_request_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _chatsCollection = 'chats';
  final String _messagesCollection = 'messages';
  final String _requestsCollection = 'chatRequests';

  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection(_messagesCollection)
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      await _firestore
          .collection(_messagesCollection)
          .doc(message.messageId)
          .set(message.toMap());

      await _firestore.collection(_chatsCollection).doc(chatId).update({
        'lastMessage': message.content,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection(_chatsCollection)
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromMap(doc.data())).toList());
  }

  Stream<List<ChatRequestModel>> getPendingRequests(String userId) {
    return _firestore
        .collection(_requestsCollection)
        .where('receiverId', isEqualTo: userId)
        .where('status',
            isEqualTo: ChatRequestStatus.pending.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRequestModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> acceptChatRequest(String requestId) async {
    try {
      final doc =
          await _firestore.collection(_requestsCollection).doc(requestId).get();
      if (!doc.exists) throw Exception('Chat request not found');

      final request = ChatRequestModel.fromMap(doc.data()!);

      // Create a new chat
      final chatId = DateTime.now().millisecondsSinceEpoch.toString();
      final chat = ChatModel(
        id: chatId,
        participants: [request.senderId, request.receiverId],
        isGroup: false,
        lastMessage: 'Chat started',
        lastMessageTime: DateTime.now(),
        readStatus: {
          request.senderId: true,
          request.receiverId: true,
        },
      );

      // Update request status
      await _firestore.collection(_requestsCollection).doc(requestId).update({
        'status': ChatRequestStatus.accepted.toString().split('.').last,
      });

      // Create chat document
      await _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .set(chat.toMap());
    } catch (e) {
      throw Exception('Failed to accept chat request: $e');
    }
  }

  Future<void> rejectChatRequest(String requestId) async {
    try {
      await _firestore.collection(_requestsCollection).doc(requestId).update({
        'status': ChatRequestStatus.rejected.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to reject chat request: $e');
    }
  }

  Future<void> sendChatRequest(ChatRequestModel request) async {
    try {
      await _firestore
          .collection(_requestsCollection)
          .doc(request.requestId)
          .set(request.toMap());
    } catch (e) {
      throw Exception('Failed to send chat request: $e');
    }
  }

  Future<void> markMessageAsRead(String chatId, String userId) async {
    try {
      await _firestore.collection(_chatsCollection).doc(chatId).update({
        'readStatus.$userId': true,
      });
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }
}
