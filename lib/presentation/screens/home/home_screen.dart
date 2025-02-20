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
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String initialPath;
  final Widget child;

  const HomeScreen({
    super.key,
    required this.initialPath,
    required this.child,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentIndex;

  final List<({String label, IconData icon, String route})> _navigationItems = [
    (label: 'Home', icon: Icons.home, route: '/home'),
    (
      label: 'Organizations',
      icon: Icons.business,
      route: '/home/organizations'
    ),
    (
      label: 'Rescue',
      icon: Icons.warning_rounded,
      route: '/home/rescue-requests'
    ),
    (label: 'Map', icon: Icons.map, route: '/home/map'),
    (label: 'Profile', icon: Icons.person, route: '/home/profile'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = _getInitialIndex();
  }

  int _getInitialIndex() {
    return _navigationItems
        .indexWhere((item) => widget.initialPath.startsWith(item.route));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          context.go(_navigationItems[index].route);
        },
        destinations: _navigationItems.map((item) {
          if (item.route == '/home/rescue-requests') {
            return NavigationDestination(
              icon: Icon(item.icon, color: Theme.of(context).colorScheme.error),
              label: item.label,
            );
          }
          return NavigationDestination(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      extendBody: true,
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
          onPressed: () => _showQuickActions(context),
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  void _showQuickActions(BuildContext context) {
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
                  context: context,
                  icon: Icons.medical_services,
                  label: 'Health Check',
                  onTap: () {
                    context.pop();
                    context.pushNamed('healthPrediction');
                  },
                ),
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.warning_rounded,
                  label: 'Rescue Request',
                  onTap: () {
                    context.pop();
                    context.go('/home/rescue-requests');
                  },
                ),
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.restaurant,
                  label: 'Add Feeding Point',
                  onTap: () {
                    context.pop();
                    context.go('/home/feeding-points/add');
                  },
                ),
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.local_hospital,
                  label: 'Add Veterinary',
                  onTap: () {
                    context.pop();
                    context.go('/home/veterinaries/add');
                  },
                ),
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.business,
                  label: 'Register Organization',
                  onTap: () {
                    context.pop();
                    context.go('/home/organizations/register');
                  },
                ),
                _buildQuickActionButton(
                  context: context,
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
    required BuildContext context,
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
}
