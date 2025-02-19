import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      ),
      body: Center(
        child: Text('Feeding Point Details Screen - ID: $pointId'),
      ),
    );
  }
}
