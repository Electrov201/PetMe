import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VeterinaryDetailsScreen extends ConsumerWidget {
  final String vetId;

  const VeterinaryDetailsScreen({
    super.key,
    required this.vetId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinary Details'),
      ),
      body: Center(
        child: Text('Veterinary Details Screen - ID: $vetId'),
      ),
    );
  }
}
