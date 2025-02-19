import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile Settings'),
              subtitle: Text(user.email ?? 'No email'),
              onTap: () => context.go('/home/profile/settings/edit'),
            ),
            const Divider(),
          ],
          SwitchListTile(
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () => context.go('/home/profile/settings/notifications'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy & Security'),
            onTap: () => context.go('/home/profile/settings/privacy'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () => context.go('/home/profile/settings/help'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () => context.go('/home/profile/settings/about'),
          ),
          if (user != null) ...[
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
          ],
        ],
      ),
    );
  }
}
