import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddVeterinaryScreen extends ConsumerStatefulWidget {
  const AddVeterinaryScreen({super.key});

  @override
  ConsumerState<AddVeterinaryScreen> createState() =>
      _AddVeterinaryScreenState();
}

class _AddVeterinaryScreenState extends ConsumerState<AddVeterinaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Veterinary'),
      ),
      body: const Center(
        child: Text('Add Veterinary Screen - Coming Soon'),
      ),
    );
  }
}
