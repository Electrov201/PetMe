import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _newPetsEnabled = true;
  bool _rescueRequestsEnabled = true;
  bool _adoptionUpdatesEnabled = true;
  bool _newsAndTipsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushEnabled = prefs.getBool('push_notifications') ?? true;
      _emailEnabled = prefs.getBool('email_notifications') ?? true;
      _newPetsEnabled = prefs.getBool('new_pets_notifications') ?? true;
      _rescueRequestsEnabled =
          prefs.getBool('rescue_requests_notifications') ?? true;
      _adoptionUpdatesEnabled =
          prefs.getBool('adoption_updates_notifications') ?? true;
      _newsAndTipsEnabled = prefs.getBool('news_tips_notifications') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', _pushEnabled);
    await prefs.setBool('email_notifications', _emailEnabled);
    await prefs.setBool('new_pets_notifications', _newPetsEnabled);
    await prefs.setBool(
        'rescue_requests_notifications', _rescueRequestsEnabled);
    await prefs.setBool(
        'adoption_updates_notifications', _adoptionUpdatesEnabled);
    await prefs.setBool('news_tips_notifications', _newsAndTipsEnabled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notification Channels',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications on your device'),
            value: _pushEnabled,
            onChanged: (value) {
              setState(() => _pushEnabled = value);
              _saveSettings();
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive notifications via email'),
            value: _emailEnabled,
            onChanged: (value) {
              setState(() => _emailEnabled = value);
              _saveSettings();
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notification Types',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('New Pets'),
            subtitle: const Text('When new pets are available for adoption'),
            value: _newPetsEnabled,
            onChanged: _pushEnabled || _emailEnabled
                ? (value) {
                    setState(() => _newPetsEnabled = value);
                    _saveSettings();
                  }
                : null,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Rescue Requests'),
            subtitle: const Text('Updates on rescue requests in your area'),
            value: _rescueRequestsEnabled,
            onChanged: _pushEnabled || _emailEnabled
                ? (value) {
                    setState(() => _rescueRequestsEnabled = value);
                    _saveSettings();
                  }
                : null,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Adoption Updates'),
            subtitle: const Text('Status updates on adoption applications'),
            value: _adoptionUpdatesEnabled,
            onChanged: _pushEnabled || _emailEnabled
                ? (value) {
                    setState(() => _adoptionUpdatesEnabled = value);
                    _saveSettings();
                  }
                : null,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('News & Tips'),
            subtitle: const Text('Pet care tips and app updates'),
            value: _newsAndTipsEnabled,
            onChanged: _pushEnabled || _emailEnabled
                ? (value) {
                    setState(() => _newsAndTipsEnabled = value);
                    _saveSettings();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
