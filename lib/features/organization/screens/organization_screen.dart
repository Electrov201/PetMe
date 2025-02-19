import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/organization_model.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';

class OrganizationScreen extends ConsumerStatefulWidget {
  const OrganizationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends ConsumerState<OrganizationScreen> {
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
              padding: const EdgeInsets.all(AppTheme.spacing8),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          'Error: ${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final organizations = snapshot.data ?? [];
                if (organizations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          'No organizations found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  itemCount: organizations.length,
                  itemBuilder: (context, index) {
                    final org = organizations[index];
                    return OrganizationCard(
                      organization: org,
                      onReport: (reason) => _handleReport(org, reason),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/organizations/register'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Stream<List<OrganizationModel>> _getFilteredOrganizations() {
    final organizationService = ref.read(organizationServiceProvider);
    if (_selectedType != null) {
      return organizationService.streamOrganizationsByType(_selectedType!);
    }
    return organizationService.streamOrganizations();
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
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, value),
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

  Future<void> _handleReport(
      OrganizationModel organization, String reason) async {
    final organizationService = ref.read(organizationServiceProvider);
    final currentUser = ref.read(authStateProvider).value;

    if (currentUser != null) {
      await organizationService.reportOrganization(
        organization.id,
        currentUser.id,
        reason,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted')),
        );
      }
    }
  }
}

class OrganizationCard extends StatelessWidget {
  final OrganizationModel organization;
  final Function(String reason) onReport;

  const OrganizationCard({
    Key? key,
    required this.organization,
    required this.onReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: InkWell(
        onTap: () => context.push('/organizations/${organization.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (organization.images.isNotEmpty &&
                organization.images.first.isNotEmpty)
              Image.network(
                organization.images.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.business,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.business,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
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
                        onSelected: (value) =>
                            _handleMenuAction(context, value),
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
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    organization.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          organization.address,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
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
                  const SizedBox(height: AppTheme.spacing16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          onPressed: () => _launchPhone(organization.phone),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
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
          onReport(reason);
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
            const SizedBox(height: AppTheme.spacing16),
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
    // TODO: Implement phone launch using url_launcher
  }

  void _launchEmail(String email) {
    // TODO: Implement email launch using url_launcher
  }
}
