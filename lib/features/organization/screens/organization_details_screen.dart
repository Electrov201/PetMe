import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/organization_model.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class OrganizationDetailsScreen extends ConsumerStatefulWidget {
  final String organizationId;

  const OrganizationDetailsScreen({
    super.key,
    required this.organizationId,
  });

  @override
  ConsumerState<OrganizationDetailsScreen> createState() =>
      _OrganizationDetailsScreenState();
}

class _OrganizationDetailsScreenState
    extends ConsumerState<OrganizationDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final organizationStream =
        ref.watch(organizationStreamProvider(widget.organizationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Details'),
      ),
      body: organizationStream.when(
        data: (organization) {
          if (organization == null) {
            return Center(
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
                    'Organization not found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: organization.images.isNotEmpty &&
                          organization.images.first.isNotEmpty
                      ? Image.network(
                          organization.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(context).colorScheme.primary,
                              child: Icon(
                                Icons.pets,
                                size: 64,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Theme.of(context).colorScheme.primary,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.primary,
                          child: Icon(
                            Icons.pets,
                            size: 64,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              organization.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          if (organization.verificationStatus ==
                              VerificationStatus.verified)
                            const Chip(
                              label: Text('Verified'),
                              avatar: Icon(Icons.verified, size: 16),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        organization.type.toString().split('.').last,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      Text(
                        organization.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                      _buildSection(
                        context,
                        'Contact Information',
                        Column(
                          children: [
                            _buildContactTile(
                              context,
                              Icons.phone,
                              organization.phone,
                              () => _launchPhone(organization.phone),
                            ),
                            _buildContactTile(
                              context,
                              Icons.email,
                              organization.email,
                              () => _launchEmail(organization.email),
                            ),
                            _buildContactTile(
                              context,
                              Icons.language,
                              organization.website,
                              () => _launchUrl(organization.website),
                            ),
                            _buildContactTile(
                              context,
                              Icons.location_on,
                              organization.address,
                              () => _launchMaps(
                                organization.latitude,
                                organization.longitude,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                      _buildSection(
                        context,
                        'Operating Hours',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Days: ${(organization.operatingHours['weekdays'] as List).join(', ')}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            Text(
                              'Hours: ${organization.operatingHours['openingTime']} - ${organization.operatingHours['closingTime']}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                      _buildSection(
                        context,
                        'Services',
                        Wrap(
                          spacing: AppTheme.spacing8,
                          runSpacing: AppTheme.spacing8,
                          children: organization.services
                              .map(
                                (service) => Chip(
                                  label: Text(service),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing24),
                      _buildSection(
                        context,
                        'Statistics',
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              context,
                              'Rescues',
                              organization.rescueCount.toString(),
                            ),
                            _buildStat(
                              context,
                              'Adoptions',
                              organization.adoptionCount.toString(),
                            ),
                          ],
                        ),
                      ),
                      if (organization.images.length > 1) ...[
                        const SizedBox(height: AppTheme.spacing24),
                        _buildSection(
                          context,
                          'Gallery',
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: organization.images.length - 1,
                              itemBuilder: (context, index) {
                                final imageUrl = organization.images[index + 1];
                                if (imageUrl.isEmpty) return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      right: AppTheme.spacing8),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.radius8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 120,
                                          height: 120,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: 120,
                                          height: 120,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
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
                'Error loading organization',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacing8),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacing16),
        content,
      ],
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final uri = Uri.parse('geo:$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
