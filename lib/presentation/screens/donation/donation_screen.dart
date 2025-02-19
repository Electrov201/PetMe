import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/providers.dart';
import '../../../core/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';

class DonationScreen extends ConsumerStatefulWidget {
  final String petId;

  const DonationScreen({
    super.key,
    required this.petId,
  });

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  String _selectedType = 'money';

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final donationService = ref.read(donationServiceProvider);
      final userId = ref.read(authProvider).user?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Upload images if any
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final cloudinaryService = ref.read(cloudinaryServiceProvider);
        final responses =
            await cloudinaryService.uploadMultipleImages(_selectedImages);
        imageUrls = responses.map((response) => response.url).toList();
      }

      // Create donation
      await donationService.createDonation({
        'type': _selectedType,
        'amount':
            _selectedType == 'money' ? double.parse(_amountController.text) : 0,
        'description': _descriptionController.text,
        'petId': widget.petId,
        'donorId': userId,
        'status': 'pending',
        'images': imageUrls,
        'createdAt': DateTime.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation submitted successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Donation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Donation Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'money',
                    label: Text('Money'),
                    icon: Icon(Icons.attach_money),
                  ),
                  ButtonSegment(
                    value: 'supplies',
                    label: Text('Supplies'),
                    icon: Icon(Icons.inventory),
                  ),
                  ButtonSegment(
                    value: 'other',
                    label: Text('Other'),
                    icon: Icon(Icons.more_horiz),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _selectedType = selection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_selectedType == 'money')
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Attachments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Image'),
                  ),
                ],
              ),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Image.network(
                              _selectedImages[index].path,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitDonation,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Submit Donation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
