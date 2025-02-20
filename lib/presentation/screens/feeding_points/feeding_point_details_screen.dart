import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/feeding_point_model.dart';
import '../../../core/services/feeding_point_service.dart';

class FeedingPointDetailsScreen extends ConsumerWidget {
  final String pointId;

  const FeedingPointDetailsScreen({
    super.key,
    required this.pointId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding Point Details'),
        centerTitle: true,
      ),
      body: FutureBuilder<FeedingPointModel?>(
        future: FeedingPointService().getFeedingPointById(pointId),
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

          final point = snapshot.data;
          if (point == null) {
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
                    'Feeding point not found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.pets_rounded,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                point.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spacing4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing8,
                                  vertical: AppTheme.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  color: point.isActive
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1)
                                      : Theme.of(context)
                                          .colorScheme
                                          .error
                                          .withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radius16),
                                ),
                                child: Text(
                                  point.isActive ? 'Active' : 'Inactive',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: point.isActive
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
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),

                // Description Section
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  point.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Location Section
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(AppTheme.spacing16),
                    leading: Icon(
                      Icons.location_on,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text('Location Coordinates'),
                    subtitle: Text(
                      'Lat: ${point.latitude}, Long: ${point.longitude}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.directions),
                      onPressed: () {
                        // TODO: Implement directions
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
