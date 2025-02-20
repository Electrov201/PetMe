import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/feeding_point_model.dart';
import '../../../core/services/feeding_point_service.dart';
import '../../../core/theme/app_theme.dart';

class FeedingPointsScreen extends ConsumerWidget {
  const FeedingPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding Points'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<FeedingPointModel>>(
        future: FeedingPointService().getFeedingPoints(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final feedingPoints = snapshot.data!;

          if (feedingPoints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets_rounded,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    'No feeding points found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'Add a new feeding point to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            itemCount: feedingPoints.length,
            itemBuilder: (context, index) {
              final feedingPoint = feedingPoints[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppTheme.spacing16),
                  leading: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pets_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    feedingPoint.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.spacing4),
                      Text(feedingPoint.description),
                      const SizedBox(height: AppTheme.spacing8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppTheme.spacing4),
                          Expanded(
                            child: Text(
                              'Lat: ${feedingPoint.latitude}, Long: ${feedingPoint.longitude}',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing12,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: feedingPoint.isActive
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1)
                          : Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radius16),
                    ),
                    child: Text(
                      feedingPoint.isActive ? 'Active' : 'Inactive',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: feedingPoint.isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  onTap: () =>
                      context.push('/feeding-points/${feedingPoint.id}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/feeding-points/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Point'),
      ),
    );
  }
}
