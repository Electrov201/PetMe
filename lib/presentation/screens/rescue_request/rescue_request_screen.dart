import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/rescue_request_service.dart';

class RescueRequestScreen extends ConsumerStatefulWidget {
	const RescueRequestScreen({super.key});

	@override
	ConsumerState<RescueRequestScreen> createState() => _RescueRequestScreenState();
}

class _RescueRequestScreenState extends ConsumerState<RescueRequestScreen> {
	final _formKey = GlobalKey<FormState>();
	final _locationController = TextEditingController();
	final _descriptionController = TextEditingController();
	String _selectedEmergencyLevel = 'medium';

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Rescue Request'),
			),
			body: Form(
				key: _formKey,
				child: ListView(
					padding: const EdgeInsets.all(16.0),
					children: [
						TextFormField(
							controller: _locationController,
							decoration: const InputDecoration(
								labelText: 'Location',
								hintText: 'Enter the location',
								prefixIcon: Icon(Icons.location_on),
							),
							validator: (value) {
								if (value == null || value.isEmpty) {
									return 'Please enter the location';
								}
								return null;
							},
						),
						const SizedBox(height: 16),
						DropdownButtonFormField<String>(
							value: _selectedEmergencyLevel,
							decoration: const InputDecoration(
								labelText: 'Emergency Level',
								prefixIcon: Icon(Icons.warning),
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
							onChanged: (value) {
								setState(() {
									_selectedEmergencyLevel = value!;
								});
							},
						),
						const SizedBox(height: 16),
						TextFormField(
							controller: _descriptionController,
							decoration: const InputDecoration(
								labelText: 'Description',
								hintText: 'Describe the situation',
								prefixIcon: Icon(Icons.description),
							),
							maxLines: 3,
							validator: (value) {
								if (value == null || value.isEmpty) {
									return 'Please enter a description';
								}
								return null;
							},
						),
						const SizedBox(height: 32),
						ElevatedButton(
							onPressed: _submitRequest,
							child: const Text('Submit Request'),
						),
					],
				),
			),
		);
	}

	void _submitRequest() async {
		if (_formKey.currentState!.validate()) {
			try {
				// TODO: Implement rescue request submission
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('Request submitted successfully')),
				);
				Navigator.pop(context);
			} catch (e) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('Error: $e')),
				);
			}
		}
	}

	@override
	void dispose() {
		_locationController.dispose();
		_descriptionController.dispose();
		super.dispose();
	}
}