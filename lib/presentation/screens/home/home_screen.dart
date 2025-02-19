import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../features/organization/screens/organization_screen.dart';
import 'pets_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import '../chat/chat_screen.dart';
import '../rescue_request/rescue_request_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PetsScreen(),
    OrganizationScreen(),
    RescueRequestScreen(),
    MapScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildQuickActionButton(
                  icon: Icons.medical_services,
                  label: 'Health Check',
                  onTap: () {
                    context.pop();
                    context.pushNamed('healthPrediction');
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.warning_rounded,
                  label: 'Rescue Request',
                  onTap: () {
                    context.pop();
                    context.go('/home/rescue-requests');
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.restaurant,
                  label: 'Add Feeding Point',
                  onTap: () {
                    context.pop();
                    context.go('/home/feeding-points/add');
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.local_hospital,
                  label: 'Add Veterinary',
                  onTap: () {
                    context.pop();
                    context.go('/home/veterinaries/add');
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.business,
                  label: 'Register Organization',
                  onTap: () {
                    context.pop();
                    context.go('/home/organizations/register');
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.location_on,
                  label: 'Nearby Organizations',
                  onTap: () {
                    context.pop();
                    context.go('/home/organizations');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadMessagesProvider).value ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: colorScheme.surface,
        elevation: 8,
        height: 65,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.pets, color: colorScheme.onSurface),
            selectedIcon: Icon(Icons.pets, color: colorScheme.primary),
            label: 'Pets',
          ),
          NavigationDestination(
            icon: Icon(Icons.business, color: colorScheme.onSurface),
            selectedIcon: Icon(Icons.business, color: colorScheme.primary),
            label: 'Organizations',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_rounded, color: colorScheme.onSurface),
            selectedIcon:
                Icon(Icons.warning_rounded, color: colorScheme.primary),
            label: 'Rescue',
          ),
          NavigationDestination(
            icon: Icon(Icons.map, color: colorScheme.onSurface),
            selectedIcon: Icon(Icons.map, color: colorScheme.primary),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: Icon(Icons.chat, color: colorScheme.onSurface),
            ),
            selectedIcon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: Icon(Icons.chat, color: colorScheme.primary),
            ),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: colorScheme.onSurface),
            selectedIcon: Icon(Icons.person, color: colorScheme.primary),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    switch (_currentIndex) {
      case 0: // Pets screen
        return FloatingActionButton.extended(
          onPressed: () => context.go('/home/pets/add'),
          label: const Text('Add Pet'),
          icon: const Icon(Icons.add),
        );
      case 1: // Organizations screen
        return FloatingActionButton.extended(
          onPressed: () => context.go('/home/organizations/register'),
          label: const Text('Register'),
          icon: const Icon(Icons.add_business),
        );
      case 2: // Rescue screen
        return FloatingActionButton(
          onPressed: _showQuickActions,
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }
}
