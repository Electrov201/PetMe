import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddFeedingPointScreen extends ConsumerStatefulWidget {
  const AddFeedingPointScreen({super.key});

  @override
  ConsumerState<AddFeedingPointScreen> createState() =>
      _AddFeedingPointScreenState();
}

class _AddFeedingPointScreenState extends ConsumerState<AddFeedingPointScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Feeding Point'),
      ),
      body: const Center(
        child: Text('Add Feeding Point Screen - Coming Soon'),
      ),
    );
  }
}
