import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/pet_model.dart';
import '../../../core/providers/providers.dart';
import '../../widgets/pet_card.dart';

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

          final filteredPets = _filterPets(petsList);

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredPets.length,
            itemBuilder: (context, index) {
              final pet = filteredPets[index];
              return PetCard(
                pet: pet,
                onTap: () => context.pushNamed(
                  'pet-details',
                  pathParameters: {'id': pet.id},
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
