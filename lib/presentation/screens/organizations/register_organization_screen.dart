import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/organization_model.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';

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
  final List<String> _selectedServices = [];
  final List<XFile> _selectedImages = [];
  final List<String> _selectedWeekdays = [];
  TimeOfDay _openingTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isLoading = false;

  final _services = [
    'Rescue',
    'Adoption',
    'Medical Care',
    'Sterilization',
    'Vaccination',
    'Foster Care',
    'Emergency Response',
    'Animal Welfare Education',
    'Pet Training',
    'Pet Grooming',
  ];

  final _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
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

  Future<void> _pickImages() async {
    final imagePicker = ImagePicker();
    final images = await imagePicker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
        ),
      );
      return;
    }
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
        ),
      );
      return;
    }
    if (_selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select operating days'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) throw Exception('User not authenticated');

      // Upload images
      final cloudinaryService = ref.read(cloudinaryServiceProvider);
      final uploadedImages = await Future.wait(
        _selectedImages.map(
          (image) => cloudinaryService.uploadImage(File(image.path)),
        ),
      );

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Organization registered successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
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
          padding: const EdgeInsets.all(AppTheme.spacing16),
          children: [
            // Basic Information
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Organization Name',
                hintText: 'Enter your organization name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter organization name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Type
            DropdownButtonFormField<OrganizationType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Organization Type',
              ),
              items: OrganizationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter organization description',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                if (value.length < 50) {
                  return 'Description should be at least 50 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Contact Information
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter organization email',
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
            const SizedBox(height: AppTheme.spacing16),

            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter organization phone',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Website
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                hintText: 'Enter organization website',
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter website';
                }
                if (!value.startsWith('http')) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Enter organization address',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Services
            Text(
              'Services',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Wrap(
              spacing: AppTheme.spacing8,
              runSpacing: AppTheme.spacing8,
              children: _services.map((service) {
                final isSelected = _selectedServices.contains(service);
                return FilterChip(
                  label: Text(service),
                  selected: isSelected,
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
            const SizedBox(height: AppTheme.spacing24),

            // Operating Hours
            Text(
              'Operating Hours',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Wrap(
              spacing: 8,
              children: _weekdays.map((day) {
                final isSelected = _selectedWeekdays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: isSelected,
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
                    subtitle: Text(_openingTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
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
                    subtitle: Text(_closingTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
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
            const SizedBox(height: AppTheme.spacing24),

            // Images
            Text(
              'Images',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            if (_selectedImages.isEmpty)
              Center(
                child: TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Images'),
                ),
              )
            else
              Wrap(
                spacing: AppTheme.spacing8,
                runSpacing: AppTheme.spacing8,
                children: [
                  ..._selectedImages.map((image) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radius8),
                            image: DecorationImage(
                              image: FileImage(File(image.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedImages.remove(image);
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  InkWell(
                    onTap: _pickImages,
                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radius8),
                      ),
                      child: Icon(
                        Icons.add_photo_alternate,
                        size: 32,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppTheme.spacing32),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Register Organization'),
            ),
          ],
        ),
      ),
    );
  }
}
