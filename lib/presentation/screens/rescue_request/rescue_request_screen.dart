import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/rescue_request_model.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';

class RescueRequestScreen extends ConsumerStatefulWidget {
  const RescueRequestScreen({super.key});

  @override
  ConsumerState<RescueRequestScreen> createState() =>
      _RescueRequestScreenState();
}

class _RescueRequestScreenState extends ConsumerState<RescueRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedEmergencyLevel = 'medium';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check authentication state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;

    // Show loading if auth state is being checked
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rescue Request'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          children: [
            // Location Field
            TextFormField(
              controller: _locationController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'Enter the location',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the location';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Emergency Level Dropdown
            DropdownButtonFormField<String>(
              value: _selectedEmergencyLevel,
              decoration: InputDecoration(
                labelText: 'Emergency Level',
                prefixIcon: const Icon(Icons.warning),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'low',
                  child: Text('Low'),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'high',
                  child: Text('High'),
                ),
                DropdownMenuItem(
                  value: 'critical',
                  child: Text('Critical'),
                ),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedEmergencyLevel = value!;
                      });
                    },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the situation',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                if (value.length < 20) {
                  return 'Description should be at least 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing32),

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radius12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Submit Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final request = RescueRequestModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.id,
        location: _locationController.text,
        description: _descriptionController.text,
        emergencyLevel: _stringToEmergencyLevel(_selectedEmergencyLevel),
        createdAt: Timestamp.now(),
      );

      await ref
          .read(rescueRequestRepositoryProvider)
          .createRescueRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Request submitted successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().split(': ').last}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // If authentication error, redirect to login
        if (e.toString().contains('not authenticated')) {
          context.go('/login');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  EmergencyLevel _stringToEmergencyLevel(String level) {
    switch (level) {
      case 'low':
        return EmergencyLevel.low;
      case 'medium':
        return EmergencyLevel.medium;
      case 'high':
        return EmergencyLevel.high;
      case 'critical':
        return EmergencyLevel.critical;
      default:
        return EmergencyLevel.medium;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
