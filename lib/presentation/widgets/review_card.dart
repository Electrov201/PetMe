import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/models/review_model.dart';
import '../../core/theme/app_theme.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isOwner;

  const ReviewCard({
    super.key,
    required this.review,
    this.onEdit,
    this.onDelete,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: review.userPhotoUrl != null
                      ? NetworkImage(review.userPhotoUrl!)
                      : null,
                  child: review.userPhotoUrl == null
                      ? Text(review.userName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        timeago.format(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isOwner) ...[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppTheme.spacing8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(review.comment),
            if (review.photos.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacing8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radius8),
                        child: Image.network(
                          review.photos[index],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
