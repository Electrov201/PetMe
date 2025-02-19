import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please login to view your profile'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(user.displayName ?? 'User Profile'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (user.photoURL != null)
                    Image.network(
                      user.photoURL!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: Theme.of(context).primaryColor,
                      child: const Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.pets),
                title: const Text('My Pets'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/home/profile/my-pets'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favorites'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/home/profile/favorites'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Activity History'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/home/profile/activity-history'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/home/profile/settings'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
