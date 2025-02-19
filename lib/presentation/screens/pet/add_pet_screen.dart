import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/pet_model.dart';
import '../../../core/services/pet_service.dart';
import '../../../core/services/cloudinary_service.dart';

class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'dog';
  String _selectedGender = 'male';
  List<XFile> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  bool _isLoading = false;

  final _petService = PetService();
  final _cloudinaryService = CloudinaryService();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  Future<void> _addPet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload images to Cloudinary
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final responses =
            await _cloudinaryService.uploadMultipleImages(_selectedImages);
        imageUrls = responses.map((response) => response.url).toList();
      }

      final userId = ref.read(authProvider).user?.uid;
      if (userId == null) throw Exception('User not logged in');

      final pet = PetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        name: _nameController.text.trim(),
        type: _selectedType,
        breed: _breedController.text.trim(),
        description: _descriptionController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        latitude: 0, // TODO: Get current location
        longitude: 0,
        reporterId: userId,
        status: PetStatus.available,
        reportedAt: DateTime.now(),
        images: imageUrls,
      );

      await _petService.addPet(pet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet added successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding pet: $e')),
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
        title: const Text('Add Pet'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Pet Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pet name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Pet Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'dog', child: Text('Dog')),
                DropdownMenuItem(value: 'cat', child: Text('Cat')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _breedController,
              decoration: const InputDecoration(
                labelText: 'Breed',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter breed';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age (years)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter age';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedGender = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Photo'),
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
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
                          kIsWeb
                              ? Image.network(
                                  _selectedImages[index].path,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedImages[index].path),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle),
                              color: Colors.red,
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
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addPet,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Pet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
