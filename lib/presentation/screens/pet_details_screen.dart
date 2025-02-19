import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../../../core/models/pet_model.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';

class PetDetailsScreen extends ConsumerWidget {
  final String petId;

  const PetDetailsScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petStream = ref.watch(petStreamProvider(petId));
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      body: petStream.when(
        data: (pet) {
          if (pet == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    'Pet not found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          }

          final isLiked =
              currentUser != null && pet.likedBy.contains(currentUser.id);

          return Stack(
            children: [
              // Full-screen background image with gradient overlay
              Hero(
                tag: 'pet-${pet.id}',
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        pet.images.isNotEmpty
                            ? pet.images.first
                            : 'https://via.placeholder.com/500',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Scrollable content with frosted glass effect
              CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: true,
                    expandedHeight: MediaQuery.of(context).size.height * 0.4,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () async {
                          await Share.share(
                            'Check out ${pet.name} on PetMe!',
                            subject: 'Share Pet',
                          );
                          if (context.mounted) {
                            ref
                                .read(petRepositoryProvider)
                                .incrementShares(pet.id);
                          }
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Pet Info
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(AppTheme.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pet Name and Status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pet.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing12,
                                  vertical: AppTheme.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  color: pet.status == PetStatus.available
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.2)
                                      : Theme.of(context)
                                          .colorScheme
                                          .error
                                          .withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radius16),
                                ),
                                child: Text(
                                  pet.status.toString().split('.').last,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: pet.status == PetStatus.available
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing8),

                          // Pet Details
                          Row(
                            children: [
                              Icon(
                                pet.gender == 'male'
                                    ? Icons.male
                                    : Icons.female,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spacing4),
                              Text(
                                '${pet.age} years old',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(width: AppTheme.spacing8),
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spacing4),
                              Text(
                                '${pet.latitude}, ${pet.longitude}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing16),

                          // Social Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _SocialButton(
                                icon: isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                label: '${pet.likedBy.length} Likes',
                                color: isLiked
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                onPressed: currentUser == null
                                    ? null
                                    : () => ref
                                        .read(petRepositoryProvider)
                                        .toggleLike(pet.id),
                              ),
                              _SocialButton(
                                icon: Icons.comment_outlined,
                                label: '${pet.comments.length} Comments',
                                onPressed: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      _CommentsSheet(pet: pet),
                                ),
                              ),
                              _SocialButton(
                                icon: Icons.share_outlined,
                                label: '${pet.shares} Shares',
                                onPressed: () async {
                                  await Share.share(
                                    'Check out ${pet.name} on PetMe!',
                                    subject: 'Share Pet',
                                  );
                                  if (context.mounted) {
                                    ref
                                        .read(petRepositoryProvider)
                                        .incrementShares(pet.id);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing24),

                          // Description
                          Text(
                            'About',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: AppTheme.spacing8),
                          Text(
                            pet.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: AppTheme.spacing24),

                          // Medical History
                          if (pet.medicalHistory != null &&
                              pet.medicalHistory!.isNotEmpty) ...[
                            Text(
                              'Medical History',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            ...pet.medicalHistory!.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppTheme.spacing8),
                                child: Row(
                                  children: [
                                    Text(
                                      '${entry.key}:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: AppTheme.spacing8),
                                    Text(
                                      entry.value.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing24),
                          ],

                          // Behavior Notes
                          if (pet.behavior != null &&
                              pet.behavior!.isNotEmpty) ...[
                            Text(
                              'Behavior Notes',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            ...pet.behavior!.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppTheme.spacing8),
                                child: Row(
                                  children: [
                                    Text(
                                      '${entry.key}:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: AppTheme.spacing8),
                                    Text(
                                      entry.value.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Error loading pet details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.radius8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing8,
            vertical: AppTheme.spacing4,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color ?? Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: AppTheme.spacing2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color ?? Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentsSheet extends ConsumerStatefulWidget {
  final PetModel pet;

  const _CommentsSheet({required this.pet});

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet>
    with SingleTickerProviderStateMixin {
  final _commentController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.normalDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a comment'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(petRepositoryProvider).addComment(
            widget.pet.id,
            text,
          );
      _commentController.clear();
      if (mounted) {
        await _animationController.reverse();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Comment added successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to add comment: ${e.toString().split(': ').last}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final height = MediaQuery.of(context).size.height * 0.7;

    if (currentUser == null) {
      return Container(
        height: height * 0.3,
        margin: const EdgeInsets.all(AppTheme.spacing16),
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(AppTheme.radius24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radius24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Please sign in to comment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.spacing16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to sign in screen
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(_animation),
        child: Container(
          height: height,
          margin: const EdgeInsets.all(AppTheme.spacing16),
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(AppTheme.radius24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radius24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  AppBar(
                    title: Text('Comments (${widget.pet.comments.length})'),
                    backgroundColor: Colors.transparent,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          await _animationController.reverse();
                          if (mounted) Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: widget.pet.comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.4),
                                ),
                                const SizedBox(height: AppTheme.spacing8),
                                Text(
                                  'No comments yet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                ),
                                if (currentUser != null) ...[
                                  const SizedBox(height: AppTheme.spacing4),
                                  Text(
                                    'Be the first to comment!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: widget.pet.comments.length,
                            padding: const EdgeInsets.all(AppTheme.spacing16),
                            itemBuilder: (context, index) {
                              final comment = widget.pet.comments[index];
                              final isLastComment =
                                  index == widget.pet.comments.length - 1;

                              return TweenAnimationBuilder<double>(
                                duration: AppTheme.normalDuration,
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (0.2 * value),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    bottom:
                                        isLastComment ? 0 : AppTheme.spacing8,
                                  ),
                                  padding:
                                      const EdgeInsets.all(AppTheme.spacing12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radius12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                            child: Text(
                                              comment['userName'][0]
                                                  .toUpperCase(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppTheme.spacing8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  comment['userName'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Text(
                                                  comment['timestamp'] != null
                                                      ? _formatTimestamp(
                                                          comment['timestamp']
                                                              as Timestamp)
                                                      : 'Just now',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.5),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppTheme.spacing8),
                                      Text(
                                        comment['text'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (currentUser != null)
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.8),
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radius12),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                enabled: !_isLoading,
                                prefixIcon:
                                    const Icon(Icons.chat_bubble_outline),
                              ),
                              onSubmitted: (_) => _addComment(),
                              textInputAction: TextInputAction.send,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing8),
                          IconButton.filled(
                            icon: AnimatedSwitcher(
                              duration: AppTheme.quickDuration,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send),
                            ),
                            onPressed: _isLoading ? null : _addComment,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final commentTime = timestamp.toDate();
    final difference = now.difference(commentTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(commentTime);
    }
  }
}
