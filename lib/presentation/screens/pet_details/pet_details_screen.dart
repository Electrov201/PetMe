import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/pet_model.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';

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
            return const Center(child: Text('Pet not found'));
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
                        onPressed: () {
                          Share.share(
                            'Check out ${pet.name} on PetMe! A ${pet.age} year old ${pet.breed}.',
                          );
                          ref
                              .read(petRepositoryProvider)
                              .incrementShares(pet.id);
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
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radius32),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withOpacity(0.9),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppTheme.radius32),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pet Status and Actions
                              Padding(
                                padding:
                                    const EdgeInsets.all(AppTheme.spacing16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacing12,
                                        vertical: AppTheme.spacing8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.radius16),
                                      ),
                                      child: Text(
                                        pet.status.name.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _ActionButton(
                                          icon: isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          label: pet.likedBy.length.toString(),
                                          color: isLiked ? Colors.red : null,
                                          onTap: () {
                                            if (currentUser == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Please sign in to like pets'),
                                                ),
                                              );
                                              return;
                                            }
                                            ref
                                                .read(petRepositoryProvider)
                                                .toggleLike(pet.id);
                                          },
                                        ),
                                        const SizedBox(
                                            width: AppTheme.spacing8),
                                        _ActionButton(
                                          icon: Icons.comment_outlined,
                                          label: pet.comments.length.toString(),
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (context) =>
                                                  _CommentsSheet(pet: pet),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Pet Name and Basic Info
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.spacing16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            pet.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        Icon(
                                          pet.gender.toLowerCase() == 'male'
                                              ? Icons.male_rounded
                                              : Icons.female_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 32,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppTheme.spacing8),
                                    Text(
                                      '${pet.breed} • ${pet.age} years',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7),
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              // Description
                              Padding(
                                padding:
                                    const EdgeInsets.all(AppTheme.spacing16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'About',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing8),
                                    Text(
                                      pet.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            height: 1.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              // Location
                              if (pet.latitude != 0 && pet.longitude != 0)
                                Padding(
                                  padding:
                                      const EdgeInsets.all(AppTheme.spacing16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Location',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: AppTheme.spacing8),
                                      AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radius16),
                                          child: Container(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            // TODO: Add map widget here
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Contact Button
                              Padding(
                                padding:
                                    const EdgeInsets.all(AppTheme.spacing16),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement contact functionality
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  child: const Text('Contact Owner'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing12,
          vertical: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppTheme.radius8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: AppTheme.spacing4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
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

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
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
        Navigator.pop(context); // Close sheet after successful comment
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
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

    return Container(
      height: height,
      margin: const EdgeInsets.all(AppTheme.spacing16),
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radius24),
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: widget.pet.comments.isEmpty
                    ? Center(
                        child: Text(
                          'No comments yet',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.pet.comments.length,
                        padding: const EdgeInsets.all(AppTheme.spacing16),
                        itemBuilder: (context, index) {
                          final comment = widget.pet.comments[index];
                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: AppTheme.spacing8),
                            padding: const EdgeInsets.all(AppTheme.spacing12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.8),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radius12),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment['userName'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spacing4),
                                Text(
                                  comment['text'],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (currentUser != null)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(0.8),
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
                            fillColor: Theme.of(context).colorScheme.surface,
                            enabled: !_isLoading,
                          ),
                          onSubmitted: (_) => _addComment(),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      IconButton.filled(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        onPressed: _isLoading ? null : _addComment,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
