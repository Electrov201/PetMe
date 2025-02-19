import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/pet_model.dart';
import '../../../core/providers/providers.dart';
import '../../../core/providers/auth_provider.dart';

class PetDetailsScreen extends ConsumerStatefulWidget {
  final String petId;
  final String userId;

  const PetDetailsScreen({
    super.key,
    required this.petId,
    required this.userId,
  });

  @override
  ConsumerState<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends ConsumerState<PetDetailsScreen> {
  bool _isLoading = true;
  PetModel? _pet;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  Future<void> _loadPet() async {
    try {
      final petService = ref.read(petServiceProvider);
      final pet = await petService.getPetById(widget.userId, widget.petId);
      setState(() {
        _pet = pet;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPet,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pet == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Pet not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_pet!.name),
              background: Hero(
                tag: 'pet-image-${_pet!.id}',
                child: _pet!.images.isNotEmpty
                    ? Image.network(
                        _pet!.images.first,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.pets,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoRow('Type', _pet!.type.toUpperCase()),
                _buildInfoRow('Breed', _pet!.breed),
                _buildInfoRow('Age', '${_pet!.age} years'),
                _buildInfoRow('Gender', _pet!.gender.toUpperCase()),
                _buildInfoRow(
                    'Status', _pet!.status.toString().split('.').last),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_pet!.description),
                if (_pet!.images.length > 1) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Photos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pet!.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _pet!.images[index],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (_pet!.medicalHistory != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Medical History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _pet!.medicalHistory!.entries
                            .map(
                                (e) => _buildInfoRow(e.key, e.value.toString()))
                            .toList(),
                      ),
                    ),
                  ),
                ],
                if (_pet!.behavior != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Behavior',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _pet!.behavior!.entries
                            .map(
                                (e) => _buildInfoRow(e.key, e.value.toString()))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildActionButtons(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final currentUser = ref.watch(authProvider).user;
    final isOwner = currentUser?.uid == _pet!.ownerId;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!isOwner && _pet!.status == PetStatus.available)
          FloatingActionButton.extended(
            onPressed: () => context.push('/donations/new/${_pet!.id}'),
            icon: const Icon(Icons.favorite),
            label: const Text('Adopt Me'),
            heroTag: 'adopt-button',
          ),
        if (isOwner)
          FloatingActionButton(
            onPressed: () => context.push('/pets/${_pet!.id}/edit'),
            child: const Icon(Icons.edit),
            heroTag: 'edit-button',
          ),
      ],
    );
  }
}
