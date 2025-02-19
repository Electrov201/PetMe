import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

final unreadMessagesProvider = StreamProvider<int>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return Stream.value(0);

  return FirebaseFirestore.instance
      .collection('chats')
      .where('participants', arrayContains: user.uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.where((doc) {
            final chat = ChatModel.fromMap(doc.data());
            return chat.readStatus[user.uid] == false;
          }).length);
});

final searchUsersProvider = StreamProvider.family<List<UserModel>, String>(
  (ref, query) {
    if (query.isEmpty) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList());
  },
);
