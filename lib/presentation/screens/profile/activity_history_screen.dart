import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityHistoryScreen extends ConsumerStatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  ConsumerState<ActivityHistoryScreen> createState() =>
      _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends ConsumerState<ActivityHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider).user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view your activity history')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('activity_history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final activities = snapshot.data!.docs;

          if (activities.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No activity history yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index].data() as Map<String, dynamic>;
              final timestamp = (activity['timestamp'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: _getActivityIcon(activity['type']),
                  title: Text(activity['description'] ?? 'Unknown activity'),
                  subtitle: Text(timeago.format(timestamp)),
                  trailing: activity['actionable'] == true
                      ? IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            if (activity['route'] != null) {
                              context.go(activity['route']);
                            }
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getActivityIcon(String? type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'pet_added':
        iconData = Icons.pets;
        iconColor = Colors.blue;
        break;
      case 'favorite_added':
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'appointment_scheduled':
        iconData = Icons.calendar_today;
        iconColor = Colors.green;
        break;
      case 'profile_updated':
        iconData = Icons.person;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.history;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor),
    );
  }
}
