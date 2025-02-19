import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/pet_model.dart';

class MyPetsScreen extends ConsumerStatefulWidget {
  const MyPetsScreen({super.key});

  @override
  ConsumerState<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends ConsumerState<MyPetsScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view your pets')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/home/pets/add'),
            tooltip: 'Add Pet',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('pets')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pets = snapshot.data!.docs;

          if (pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No pets added yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home/pets/add'),
                    child: const Text('Add Pet'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final data = pets[index].data() as Map<String, dynamic>;
              data['id'] = pets[index].id; // Add document ID to the map
              final pet = PetModel.fromMap(data);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: pet.images.isNotEmpty
                        ? NetworkImage(pet.images.first)
                        : null,
                    child: pet.images.isEmpty ? const Icon(Icons.pets) : null,
                  ),
                  title: Text(pet.name),
                  subtitle: Text('${pet.breed} • ${pet.age} years old'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.go('/home/pets/${pet.id}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
