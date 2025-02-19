import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/repositories/health_prediction_repository.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/providers/providers.dart';
import 'prediction_history_screen.dart';

class HealthPredictionScreen extends ConsumerStatefulWidget {
  const HealthPredictionScreen({super.key});

  @override
  ConsumerState<HealthPredictionScreen> createState() =>
      _HealthPredictionScreenState();
}

class _HealthPredictionScreenState
    extends ConsumerState<HealthPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  late final HealthPredictionRepository _healthRepo;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedPetType = 'dog';
  String? _selectedBreed;
  final List<String> _selectedSymptoms = [];
  bool _isLoading = false;
  Map<String, dynamic>? _prediction;
  List<File> _selectedImages = [];

  List<String> _commonSymptoms = [];
  List<String> _breedSpecificSymptoms = [];

  @override
  void initState() {
    super.initState();
    _healthRepo = ref.read(healthPredictionRepositoryProvider);
    _loadSymptoms();
  }

  Future<void> _loadSymptoms() async {
    try {
      final commonSymptoms =
          await _healthRepo.getCommonSymptoms(_selectedPetType);
      setState(() {
        _commonSymptoms = commonSymptoms;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading symptoms: $e')),
        );
      }
    }
  }

  Future<void> _loadBreedSpecificSymptoms() async {
    if (_selectedBreed == null) return;

    try {
      final symptoms =
          await _healthRepo.getBreedSpecificSymptoms(_selectedBreed!);
      setState(() {
        _breedSpecificSymptoms = symptoms;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading breed symptoms: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _uploadImagesAndGetPrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      List<XFile> xFiles =
          _selectedImages.map((file) => XFile(file.path)).toList();
      List<String> imageUrls = [];
      if (xFiles.isNotEmpty) {
        imageUrls = (await _cloudinaryService.uploadMultipleImages(xFiles))
            .cast<String>();
      }

      final prediction = await _healthRepo.getPetHealthPrediction(
        symptoms: _selectedSymptoms,
        petType: _selectedPetType,
        age: int.parse(_ageController.text),
        breed: _selectedBreed,
        imageUrls: imageUrls,
      );

      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });

      _showPredictionDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showPredictionDialog() {
    if (_prediction == null) return;

    final severity = _prediction!['severity'] as double;
    final Color severityColor = severity < 0.3
        ? Colors.green
        : severity < 0.6
            ? Colors.orange
            : Colors.red;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Prediction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prediction: ${_prediction!['prediction']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Severity: ',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: severityColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(severity * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Recommendations:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...(_prediction!['recommendations'] as List<String>).map(
                (recommendation) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(recommendation)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Health Prediction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PredictionHistoryScreen(),
              ),
            ),
            tooltip: 'View History',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedPetType,
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
                  setState(() {
                    _selectedPetType = value;
                    _selectedBreed = null;
                    _selectedSymptoms.clear();
                  });
                  _loadSymptoms();
                }
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
                  return 'Please enter the pet\'s age';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_selectedPetType == 'dog') ...[
              DropdownButtonFormField<String>(
                value: _selectedBreed,
                decoration: const InputDecoration(
                  labelText: 'Breed (optional)',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'labrador', child: Text('Labrador')),
                  DropdownMenuItem(
                    value: 'german_shepherd',
                    child: Text('German Shepherd'),
                  ),
                  DropdownMenuItem(
                    value: 'golden_retriever',
                    child: Text('Golden Retriever'),
                  ),
                  DropdownMenuItem(
                    value: 'bulldog',
                    child: Text('Bulldog'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedBreed = value);
                  _loadBreedSpecificSymptoms();
                },
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Select Symptoms:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ..._commonSymptoms.map(
                  (symptom) => FilterChip(
                    label: Text(symptom),
                    selected: _selectedSymptoms.contains(symptom),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                  ),
                ),
                if (_breedSpecificSymptoms.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._breedSpecificSymptoms.map(
                    (symptom) => FilterChip(
                      label: Text(symptom),
                      selected: _selectedSymptoms.contains(symptom),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSymptoms.add(symptom);
                          } else {
                            _selectedSymptoms.remove(symptom);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Photos (Optional):',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: _pickImage,
                  tooltip: 'Add Photo',
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
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.file(
                            _selectedImages[index],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadImagesAndGetPrediction,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Get Prediction'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }
}
