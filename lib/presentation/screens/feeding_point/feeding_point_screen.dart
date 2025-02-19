import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/feeding_point_model.dart';
import '../../../core/services/feeding_point_service.dart';

class FeedingPointScreen extends ConsumerWidget {
  const FeedingPointScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding Points'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add feeding point screen
            },
          ),
        ],
      ),
      body: FutureBuilder<List<FeedingPointModel>>(
        future: FeedingPointService().getFeedingPoints(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final feedingPoints = snapshot.data!;

          if (feedingPoints.isEmpty) {
            return const Center(child: Text('No feeding points found'));
          }

          return ListView.builder(
            itemCount: feedingPoints.length,
            itemBuilder: (context, index) {
              final feedingPoint = feedingPoints[index];
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(feedingPoint.name),
                subtitle: Text(feedingPoint.description),
                trailing: Text(feedingPoint.isActive ? 'Active' : 'Inactive'),
                onTap: () {
                  // TODO: Navigate to feeding point details screen
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add feeding point screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
