import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/organization_model.dart';
import '../../../core/models/organization_post_model.dart';
import '../../../core/services/organization_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrganizationPostsScreen extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  const OrganizationPostsScreen({
    Key? key,
    required this.organization,
  }) : super(key: key);

  @override
  ConsumerState<OrganizationPostsScreen> createState() =>
      _OrganizationPostsScreenState();
}

class _OrganizationPostsScreenState
    extends ConsumerState<OrganizationPostsScreen> {
  final OrganizationService _organizationService = OrganizationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.organization.name} Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _organizationService
            .streamOrganizationPosts(widget.organization.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data?.docs ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = OrganizationPostModel.fromMap({
                ...posts[index].data() as Map<String, dynamic>,
                'id': posts[index].id,
              });
              return PostCard(
                post: post,
                organization: widget.organization,
                onDelete: () => _deletePost(post.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddPostDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    PostType selectedType = PostType.general;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<PostType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Post Type'),
                items: PostType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter post title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter post content',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'title': titleController.text,
                  'content': contentController.text,
                  'type': selectedType,
                });
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _organizationService.createOrganizationPost(
        widget.organization.id,
        {
          'title': result['title'],
          'content': result['content'],
          'type': result['type'].toString().split('.').last,
          'authorId': 'currentUserId', // TODO: Get from auth provider
          'images': [], // TODO: Add image upload functionality
        },
      );
    }
  }

  Future<void> _deletePost(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _organizationService.deleteOrganizationPost(
        widget.organization.id,
        postId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted')),
        );
      }
    }
  }
}

class PostCard extends StatelessWidget {
  final OrganizationPostModel post;
  final OrganizationModel organization;
  final VoidCallback onDelete;

  const PostCard({
    Key? key,
    required this.post,
    required this.organization,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(post.title),
            subtitle: Text(timeago.format(post.createdAt)),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value),
              itemBuilder: (context) => [
                if (post.authorId ==
                    'currentUserId') // TODO: Get from auth provider
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete'),
                    ),
                  ),
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: ListTile(
                    leading: Icon(Icons.flag),
                    title: Text('Report'),
                  ),
                ),
              ],
            ),
          ),
          if (post.images.isNotEmpty)
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.network(
                post.images.first,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.content),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(context, Icons.thumb_up, '${post.likeCount}'),
                    _buildStat(context, Icons.share, '${post.shareCount}'),
                    _buildStat(context, Icons.comment, '${post.commentCount}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(value),
      ],
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'delete':
        onDelete();
        break;
      case 'share':
        await Share.share(
          '${post.title}\n\n'
          '${post.content}\n\n'
          'Shared from ${organization.name} on PetMe',
        );
        break;
      case 'report':
        // TODO: Implement post reporting
        break;
    }
  }
}
