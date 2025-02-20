import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/organization_model.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class OrganizationScreen extends ConsumerWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyOrganizations = ref.watch(nearbyOrganizationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Organizations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filters
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: nearbyOrganizations.when(
                data: (organizations) {
                  if (organizations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          Text(
                            'No organizations found nearby',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      left: AppTheme.spacing16,
                      right: AppTheme.spacing16,
                      top: AppTheme.spacing16,
                      bottom: AppTheme.spacing16,
                    ),
                    itemCount: organizations.length,
                    itemBuilder: (context, index) {
                      final organization = organizations[index];
                      final photos = organization['photos'] as List<dynamic>?;
                      final photoReference = photos?.isNotEmpty == true
                          ? photos?.first['photo_reference'] as String?
                          : null;

                      return Card(
                        margin:
                            const EdgeInsets.only(bottom: AppTheme.spacing16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (photoReference != null)
                              FutureBuilder<String>(
                                future: ref
                                    .read(placesServiceProvider)
                                    .getPlacePhoto(photoReference),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.network(
                                      snapshot.data!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return const SizedBox(height: 200);
                                },
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
                                          organization['name'] as String? ??
                                              'Unknown',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      if (organization['rating'] != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppTheme.spacing8,
                                            vertical: AppTheme.spacing4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                                AppTheme.radius16),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                organization['rating']
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: AppTheme.spacing8),
                                  if (organization['vicinity'] != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(
                                            width: AppTheme.spacing8),
                                        Expanded(
                                          child: Text(
                                            organization['vicinity'] as String,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: AppTheme.spacing16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          final placeId =
                                              organization['place_id']
                                                  as String;
                                          context
                                              .push('/organizations/$placeId');
                                        },
                                        icon: const Icon(Icons.info),
                                        label: const Text('Details'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          final lat = organization['geometry']
                                              ['location']['lat'] as double;
                                          final lng = organization['geometry']
                                              ['location']['lng'] as double;
                                          _launchMaps(lat, lng);
                                        },
                                        icon: const Icon(Icons.directions),
                                        label: const Text('Directions'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      Text(
                        'Error loading organizations',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.refresh(nearbyOrganizationsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final uri = Uri.parse('geo:$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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
