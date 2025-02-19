import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/pet_model.dart';
import '../../../core/providers/providers.dart';

class PetsScreen extends ConsumerStatefulWidget {
  const PetsScreen({super.key});

  @override
  ConsumerState<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends ConsumerState<PetsScreen> {
  String _searchQuery = '';
  PetType _selectedType = PetType.all;

  List<PetModel> _filterPets(List<PetModel> pets) {
    return pets.where((pet) {
      final matchesSearch =
          pet.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              pet.breed.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType =
          _selectedType == PetType.all || pet.type == _selectedType.name;
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.pushNamed('add-new-pet'),
          ),
        ],
      ),
      body: pets.when(
        data: (petsList) {
          if (petsList.isEmpty) {
            return const Center(
              child: Text('No pets available'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: petsList.length,
            itemBuilder: (context, index) {
              final pet = petsList[index];
              return GestureDetector(
                onTap: () {
                  context.pushNamed(
                    'pet-details',
                    pathParameters: {'id': pet.id},
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Hero(
                          tag: 'pet-image-${pet.id}', // Updated unique tag
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(pet.images.isNotEmpty
                                    ? pet.images[0]
                                    : 'https://via.placeholder.com/150'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pet.breed} • ${pet.age} years',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

enum PetType {
  all,
  dog,
  cat,
  other,
}
