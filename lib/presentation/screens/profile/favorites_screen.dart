import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view your favorites')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pets'),
              Tab(text: 'Veterinaries'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFavoritesList('favorite_pets'),
            _buildFavoritesList('favorite_vets'),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(String collectionName) {
    final userId = ref.watch(authProvider).user?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(collectionName)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final favorites = snapshot.data!.docs;

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No favorite ${collectionName == 'favorite_pets' ? 'pets' : 'veterinaries'} yet',
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final data = favorites[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: data['images'] != null &&
                          (data['images'] as List).isNotEmpty
                      ? NetworkImage((data['images'] as List).first)
                      : null,
                  child:
                      data['images'] == null || (data['images'] as List).isEmpty
                          ? Icon(
                              collectionName == 'favorite_pets'
                                  ? Icons.pets
                                  : Icons.local_hospital,
                            )
                          : null,
                ),
                title: Text(data['name'] ?? 'Unknown'),
                subtitle: Text(
                  collectionName == 'favorite_pets'
                      ? '${data['breed']} • ${data['age']} years old'
                      : data['address'] ?? 'No address',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final route = collectionName == 'favorite_pets'
                      ? '/home/profile/my-pets/${data['id']}'
                      : '/home/veterinaries/${data['id']}';
                  context.go(route);
                },
              ),
            );
          },
        );
      },
    );
  }
}
