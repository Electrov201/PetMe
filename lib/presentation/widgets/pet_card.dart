import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/pet_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import 'package:share_plus/share_plus.dart';

class PetCard extends ConsumerWidget {
  final PetModel pet;
  final VoidCallback onTap;
  final bool isDetailed;

  const PetCard({
    super.key,
    required this.pet,
    required this.onTap,
    this.isDetailed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final isLiked = currentUser != null && pet.likedBy.contains(currentUser.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.cardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Image
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'pet-${pet.id}',
                    child: Image.network(
                      pet.images.isNotEmpty
                          ? pet.images.first
                          : 'https://via.placeholder.com/300',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: AppTheme.spacing8,
                    right: AppTheme.spacing8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(AppTheme.radius16),
                      ),
                      child: Text(
                        pet.status.name.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Pet Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing8,
                  vertical: AppTheme.spacing4,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          pet.gender.toLowerCase() == 'male'
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      '${pet.breed} • ${pet.age} years',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    // Social Interaction Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _SocialButton(
                          icon:
                              isLiked ? Icons.favorite : Icons.favorite_border,
                          label: pet.likedBy.length.toString(),
                          color: isLiked ? Colors.red : null,
                          onTap: () {
                            if (currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please sign in to like pets'),
                                ),
                              );
                              return;
                            }
                            ref.read(petRepositoryProvider).toggleLike(pet.id);
                          },
                        ),
                        _SocialButton(
                          icon: Icons.comment_outlined,
                          label: pet.comments.length.toString(),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => _CommentsSheet(pet: pet),
                            );
                          },
                        ),
                        _SocialButton(
                          icon: Icons.share_outlined,
                          label: pet.shares.toString(),
                          onTap: () async {
                            await Share.share(
                              'Check out ${pet.name} on PetMe! A ${pet.age} year old ${pet.breed}.',
                            );
                            ref
                                .read(petRepositoryProvider)
                                .incrementShares(pet.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius4),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing2,
          vertical: AppTheme.spacing2,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                  ),
            ),
          ],
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
    if (text.isEmpty) return;

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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
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
                                                  'Just now', // TODO: Add proper timestamp
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
}
