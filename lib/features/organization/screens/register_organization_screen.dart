import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:petme/core/models/organization_model.dart';
import 'package:petme/core/providers/providers.dart';
import 'package:petme/core/utils/snackbar_utils.dart';

class RegisterOrganizationScreen extends ConsumerStatefulWidget {
  const RegisterOrganizationScreen({super.key});

  @override
  ConsumerState<RegisterOrganizationScreen> createState() =>
      _RegisterOrganizationScreenState();
}

class _RegisterOrganizationScreenState
    extends ConsumerState<RegisterOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();

  OrganizationType _selectedType = OrganizationType.shelter;
  List<String> _selectedServices = [];
  List<String> _selectedWeekdays = [];
  TimeOfDay _openingTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 17, minute: 0);

  File? _logoImage;
  List<File> _galleryImages = [];
  bool _isLoading = false;

  final _services = [
    'Rescue',
    'Adoption',
    'Medical Care',
    'Grooming',
    'Training',
    'Boarding',
    'Foster Care'
  ];

  final _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickLogoImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _logoImage = File(image.path);
      });
    }
  }

  Future<void> _pickGalleryImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _galleryImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _registerOrganization() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServices.isEmpty) {
      showErrorSnackBar(context, 'Please select at least one service');
      return;
    }
    if (_selectedWeekdays.isEmpty) {
      showErrorSnackBar(context, 'Please select operating days');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) throw Exception('User not authenticated');

      // Upload images
      final cloudinaryService = ref.read(cloudinaryServiceProvider);
      List<String> uploadedImages = [];

      // Upload logo if selected
      if (_logoImage != null) {
        final logoUrl = await cloudinaryService.uploadImage(_logoImage!);
        uploadedImages.add(logoUrl);
      }

      // Upload gallery images
      if (_galleryImages.isNotEmpty) {
        final galleryUrls = await Future.wait(
          _galleryImages.map((image) => cloudinaryService.uploadImage(image)),
        );
        uploadedImages.addAll(galleryUrls);
      }

      // Create organization
      final organization = OrganizationModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        address: _addressController.text.trim(),
        latitude: 0, // TODO: Get from map
        longitude: 0, // TODO: Get from map
        type: _selectedType,
        verificationStatus: VerificationStatus.pending,
        images: uploadedImages,
        ownerId: currentUser.id,
        adminIds: [currentUser.id],
        operatingHours: {
          'weekdays': _selectedWeekdays,
          'openingTime': '${_openingTime.hour}:${_openingTime.minute}',
          'closingTime': '${_closingTime.hour}:${_closingTime.minute}',
          'timezone': DateTime.now().timeZoneName,
        },
        services: _selectedServices,
        socialMedia: {}, // TODO: Add social media links
        rescueCount: 0,
        adoptionCount: 0,
        rating: 0.0,
        reviewCount: 0,
        events: [],
        projects: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref
          .read(organizationRepositoryProvider)
          .createOrganization(organization);

      if (mounted) {
        showSuccessSnackBar(context, 'Organization registered successfully');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Failed to register organization: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Organization'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Organization Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter organization name';
                }
                return null;
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
                  return 'Please enter organization description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<OrganizationType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Organization Type',
                border: OutlineInputBorder(),
              ),
              items: OrganizationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Services Offered:'),
            Wrap(
              spacing: 8,
              children: _services.map((service) {
                return FilterChip(
                  label: Text(service),
                  selected: _selectedServices.contains(service),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedServices.add(service);
                      } else {
                        _selectedServices.remove(service);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Operating Days:'),
            Wrap(
              spacing: 8,
              children: _weekdays.map((day) {
                return FilterChip(
                  label: Text(day),
                  selected: _selectedWeekdays.contains(day),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedWeekdays.add(day);
                      } else {
                        _selectedWeekdays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Opening Time'),
                    subtitle:
                        Text('${_openingTime.hour}:${_openingTime.minute}'),
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: _openingTime,
                      );
                      if (time != null) {
                        setState(() => _openingTime = time);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Closing Time'),
                    subtitle:
                        Text('${_closingTime.hour}:${_closingTime.minute}'),
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: _closingTime,
                      );
                      if (time != null) {
                        setState(() => _closingTime = time);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickLogoImage,
              icon: const Icon(Icons.image),
              label: const Text('Select Logo'),
            ),
            if (_logoImage != null) ...[
              const SizedBox(height: 8),
              Image.file(
                _logoImage!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickGalleryImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('Add Gallery Images'),
            ),
            if (_galleryImages.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _galleryImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Image.file(
                            _galleryImages[index],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _galleryImages.removeAt(index);
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
            ElevatedButton(
              onPressed: _isLoading ? null : _registerOrganization,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Register Organization'),
            ),
          ],
        ),
      ),
    );
  }
}
