import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/organization_model.dart';
import '../../../core/models/organization_post_model.dart';
import '../../../core/services/organization_service.dart';
import 'package:share_plus/share_plus.dart';

class OrganizationsScreen extends ConsumerStatefulWidget {
  const OrganizationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrganizationsScreen> createState() =>
      _OrganizationsScreenState();
}

class _OrganizationsScreenState extends ConsumerState<OrganizationsScreen> {
  final OrganizationService _organizationService = OrganizationService();
  String _searchQuery = '';
  OrganizationType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty || _selectedType != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  if (_searchQuery.isNotEmpty)
                    Chip(
                      label: Text('Search: $_searchQuery'),
                      onDeleted: () => setState(() => _searchQuery = ''),
                    ),
                  if (_selectedType != null)
                    Chip(
                      label: Text(
                          'Type: ${_selectedType.toString().split('.').last}'),
                      onDeleted: () => setState(() => _selectedType = null),
                    ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<OrganizationModel>>(
              stream: _getFilteredOrganizations(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final organizations = snapshot.data ?? [];
                if (organizations.isEmpty) {
                  return const Center(child: Text('No organizations found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: organizations.length,
                  itemBuilder: (context, index) {
                    final org = organizations[index];
                    return OrganizationCard(organization: org);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add organization screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Stream<List<OrganizationModel>> _getFilteredOrganizations() {
    if (_selectedType != null) {
      return _organizationService.streamOrganizationsByType(_selectedType!);
    }
    return _organizationService.streamOrganizations();
  }

  Future<void> _showFilterDialog() async {
    final selectedType = await showDialog<OrganizationType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrganizationType.values
              .map(
                (type) => ListTile(
                  title: Text(type.toString().split('.').last),
                  onTap: () => Navigator.pop(context, type),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (selectedType != null) {
      setState(() => _selectedType = selectedType);
    }
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController(text: _searchQuery);
    final query = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Organizations'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter organization name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Search'),
          ),
        ],
      ),
    );

    if (query != null) {
      setState(() => _searchQuery = query);
    }
  }
}

class OrganizationCard extends ConsumerWidget {
  final OrganizationModel organization;

  const OrganizationCard({
    Key? key,
    required this.organization,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (organization.images.isNotEmpty)
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  Image.network(
                    organization.images.first,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (organization.verificationStatus ==
                      VerificationStatus.verified)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Chip(
                        label: Text('Verified'),
                        avatar: Icon(Icons.verified, size: 16),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        organization.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(context, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'share',
                          child: ListTile(
                            leading: Icon(Icons.share),
                            title: Text('Share'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'report',
                          child: ListTile(
                            leading: Icon(Icons.flag),
                            title: Text('Report'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  organization.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        organization.address,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(context, 'Rating', '${organization.rating}'),
                    _buildStat(
                        context, 'Reviews', '${organization.reviewCount}'),
                    _buildStat(
                        context, 'Rescues', '${organization.rescueCount}'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                        onPressed: () => _launchPhone(organization.phone),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.email),
                        label: const Text('Email'),
                        onPressed: () => _launchEmail(organization.email),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    final organizationService = OrganizationService();

    switch (action) {
      case 'share':
        await Share.share(
          'Check out ${organization.name} on PetMe!\n'
          '${organization.description}\n\n'
          'Address: ${organization.address}\n'
          'Phone: ${organization.phone}\n'
          'Email: ${organization.email}',
        );
        break;
      case 'report':
        final reason = await _showReportDialog(context);
        if (reason != null) {
          await organizationService.reportOrganization(
            organization.id,
            'currentUserId', // TODO: Get from auth provider
            reason,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report submitted')),
            );
          }
        }
        break;
    }
  }

  Future<String?> _showReportDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Organization'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this organization?'),
            const SizedBox(height: 16),
            ...[
              'Inappropriate content',
              'Misleading information',
              'Spam',
              'Other'
            ]
                .map(
                  (reason) => ListTile(
                    title: Text(reason),
                    onTap: () => Navigator.pop(context, reason),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  void _launchPhone(String phone) {
    // TODO: Implement phone launch
  }

  void _launchEmail(String email) {
    // TODO: Implement email launch
  }
}
