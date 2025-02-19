import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/models/chat_model.dart';
import '../../../core/models/chat_request_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Chats'), Tab(text: 'Requests')],
          ),
        ),
        body: TabBarView(children: [_buildChatsList(), _buildRequestsList()]),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showNewChatDialog(),
          child: const Icon(Icons.message),
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    final userId = ref.watch(authProvider).user?.uid;
    if (userId == null) return const Center(child: Text('Please login first'));

    return StreamBuilder<List<ChatModel>>(
      stream: _chatService.getUserChats(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data!;
        if (chats.isEmpty) {
          return const Center(child: Text('No active chats'));
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ListTile(
              leading: CircleAvatar(
                child: Icon(chat.isGroup ? Icons.group : Icons.person),
              ),
              title: Text(
                chat.isGroup
                    ? chat.groupName ?? 'Group Chat'
                    : chat.participants.where((p) => p != userId).first,
              ),
              subtitle: Text(chat.lastMessage),
              trailing: Text(
                '${chat.lastMessageTime.hour}:${chat.lastMessageTime.minute}',
                style: TextStyle(
                  color: chat.readStatus[userId] == false
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              ),
              onTap: () => _navigateToChatDetail(chat),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsList() {
    final userId = ref.watch(authProvider).user?.uid;
    if (userId == null) return const Center(child: Text('Please login first'));

    return StreamBuilder<List<ChatRequestModel>>(
      stream: _chatService.getPendingRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return const Center(child: Text('No pending requests'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('Chat Request from User ${request.senderId}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _handleRequestResponse(request, true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _handleRequestResponse(request, false),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleRequestResponse(ChatRequestModel request, bool accept) async {
    try {
      if (accept) {
        await _chatService.acceptChatRequest(request.requestId);
      } else {
        await _chatService.rejectChatRequest(request.requestId);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showNewChatDialog() {
    final TextEditingController searchController = TextEditingController();
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search users by name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                searchQuery = value;
                ref.read(searchUsersProvider(value));
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Consumer(
                builder: (context, ref, child) {
                  final searchResults =
                      ref.watch(searchUsersProvider(searchQuery));

                  return searchResults.when(
                    data: (users) {
                      if (users.isEmpty) {
                        return const Center(
                          child: Text('No users found'),
                        );
                      }

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.photoUrl != null
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(user.displayName),
                            subtitle: Text(user.email),
                            onTap: () => _sendChatRequest(user.id),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Text('Error: $error'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendChatRequest(String targetUserId) async {
    final currentUserId = ref.read(authProvider).user?.uid;
    if (currentUserId == null) return;

    try {
      final request = ChatRequestModel(
        requestId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        receiverId: targetUserId,
        status: ChatRequestStatus.pending,
        createdAt: DateTime.now(),
      );
      await _chatService.sendChatRequest(request);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat request sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _navigateToChatDetail(ChatModel chat) {
    context.goNamed(
      'chat-detail',
      pathParameters: {'chatId': chat.id},
      extra: chat,
    );
  }
}
