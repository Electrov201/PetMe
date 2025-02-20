import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../core/models/rescue_request_model.dart';
import '../../../core/providers/rescue_request_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Simple user model for the list
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
    );
  }
}

// Add a provider to get all users
final allUsersProvider = StreamProvider<List<AppUser>>((ref) {
  return FirebaseFirestore.instance.collection('users').snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList());
});

class RescueRequestScreen extends ConsumerStatefulWidget {
  const RescueRequestScreen({super.key});

  @override
  ConsumerState<RescueRequestScreen> createState() =>
      _RescueRequestScreenState();
}

class _RescueRequestScreenState extends ConsumerState<RescueRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    if (locationStatus.isGranted) {
      _getCurrentLocation();
    } else {
      final result = await Permission.location.request();
      if (result.isGranted) {
        _getCurrentLocation();
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services')),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _currentPosition = position;
        _currentAddress =
            '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission is required')),
          );
        }
        return;
      }
    }

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'rescue_requests/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
      rethrow;
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() ||
        _imageFile == null ||
        _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final request = RescueRequest(
        id: '',
        userId: userId,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _currentAddress ?? 'Unknown location',
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        imageUrl: '', // Will be set by the service
        createdAt: DateTime.now(),
      );

      await ref.read(rescueRequestServiceProvider).createRescueRequest(
            request,
            imageFile: _imageFile,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Rescue request submitted successfully')),
        );
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _imageFile = null;
        });

        // Only pop if we're successful
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rescueRequests = ref.watch(rescueRequestsProvider);
    final currentUser = ref.watch(authStateProvider).value;
    final allUsers = ref.watch(allUsersProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rescue Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Requests'),
              Tab(text: 'My Requests'),
              Tab(text: 'Available Helpers'),
            ],
          ),
        ),
        body: _isLoading
            ? const LoadingIndicator()
            : TabBarView(
                children: [
                  _buildRequestsList(rescueRequests, currentUser),
                  if (currentUser != null)
                    _buildUserRequestsList(
                      ref.watch(userRescueRequestsProvider(currentUser.uid)),
                      currentUser.uid,
                    )
                  else
                    const Center(
                        child: Text('Please login to view your requests')),
                  _buildUsersList(allUsers),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddRequestDialog(context),
          label: const Text('New Request'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildRequestsList(
      AsyncValue<List<RescueRequest>> requests, User? currentUser) {
    return requests.when(
      data: (requestsList) {
        if (requestsList.isEmpty) {
          return const Center(child: Text('No rescue requests found'));
        }
        return ListView.builder(
          itemCount: requestsList.length,
          itemBuilder: (context, index) {
            final request = requestsList[index];
            return _buildRequestCard(request, currentUser?.uid);
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildUserRequestsList(
      AsyncValue<List<RescueRequest>> requests, String userId) {
    return requests.when(
      data: (requestsList) {
        if (requestsList.isEmpty) {
          return const Center(
              child: Text('You haven\'t made any requests yet'));
        }
        return ListView.builder(
          itemCount: requestsList.length,
          itemBuilder: (context, index) {
            final request = requestsList[index];
            return _buildRequestCard(request, userId, showDeleteButton: true);
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildRequestCard(RescueRequest request, String? currentUserId,
      {bool showDeleteButton = false}) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (request.imageUrl.isNotEmpty)
            Image.network(
              request.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (request.isDone)
                      const Chip(
                        label: Text('Done'),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(request.description),
                const SizedBox(height: 8),
                Text(
                  'Location: ${request.location}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Posted: ${request.createdAt.toString().split('.')[0]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (request.handledBy != null)
                  Text(
                    'Handled by: ${request.handledBy}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (currentUserId != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!request.isDone)
                        TextButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(rescueRequestServiceProvider)
                                  .markAsDone(request.id, currentUserId);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Request marked as done')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Error marking request as done: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Mark as Done'),
                        )
                      else if (currentUserId == request.handledBy)
                        TextButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(rescueRequestServiceProvider)
                                  .markAsUndone(request.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Request marked as undone')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Error marking request as undone: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Mark as Undone'),
                        ),
                      if (showDeleteButton || currentUserId == request.userId)
                        TextButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(rescueRequestServiceProvider)
                                  .deleteRescueRequest(request);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Request deleted successfully')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error deleting request: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Delete'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(AsyncValue<List<AppUser>> users) {
    return users.when(
      data: (usersList) {
        if (usersList.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        return ListView.builder(
          itemCount: usersList.length,
          itemBuilder: (context, index) {
            final user = usersList[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    user.photoURL != null && user.photoURL!.isNotEmpty
                        ? NetworkImage(user.photoURL!)
                        : null,
                child: user.photoURL == null || user.photoURL!.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(user.displayName ?? user.email ?? 'Anonymous User'),
              subtitle: Text(user.email ?? ''),
              trailing: TextButton(
                onPressed: () {
                  // You can implement functionality to assign rescue request to this user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Selected ${user.displayName ?? 'user'} as helper'),
                    ),
                  );
                },
                child: const Text('Select'),
              ),
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  void _showAddRequestDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'New Rescue Request',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
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
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_imageFile != null)
                  Image.file(
                    _imageFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                const SizedBox(height: 16),
                if (_currentAddress != null)
                  Text(
                    'Location: $_currentAddress',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _submitRequest();
                    if (mounted && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Submit Request'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
