import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/organization_model.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:ui';

class OrganizationDetailsScreen extends ConsumerWidget {
  final String organizationId;

  const OrganizationDetailsScreen({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationStream =
        ref.watch(organizationStreamProvider(organizationId));
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
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
              // App Bar with organization image
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: organization.images.isNotEmpty
                      ? Image.network(
                          organization.images.first,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.primary,
                          child: Center(
                            child: Icon(
                              Icons.business,
                              size: 64,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                ),
              ),

              // Organization Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Verification Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              organization.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (organization.verificationStatus ==
                              VerificationStatus.verified)
                            Icon(
                              Icons.verified,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing8),

                      // Type
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
                          borderRadius: BorderRadius.circular(AppTheme.radius4),
                        ),
                        child: Text(
                          organization.type
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing16),

                      // Description
                      Text(
                        organization.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppTheme.spacing24),

                      // Contact Information
                      _SectionTitle(title: 'Contact Information'),
                      const SizedBox(height: AppTheme.spacing8),
                      _ContactItem(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: organization.phone,
                        onTap: () =>
                            launchUrl(Uri.parse('tel:${organization.phone}')),
                      ),
                      _ContactItem(
                        icon: Icons.email,
                        label: 'Email',
                        value: organization.email,
                        onTap: () => launchUrl(
                            Uri.parse('mailto:${organization.email}')),
                      ),
                      _ContactItem(
                        icon: Icons.language,
                        label: 'Website',
                        value: organization.website,
                        onTap: () => launchUrl(Uri.parse(organization.website)),
                      ),
                      _ContactItem(
                        icon: Icons.location_on,
                        label: 'Address',
                        value: organization.address,
                        onTap: () => launchUrl(Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${organization.latitude},${organization.longitude}')),
                      ),
                      const SizedBox(height: AppTheme.spacing24),

                      // Operating Hours
                      _SectionTitle(title: 'Operating Hours'),
                      const SizedBox(height: AppTheme.spacing8),
                      ...organization.operatingHours.entries.map(
                        (entry) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppTheme.spacing8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  entry.key,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value.toString(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing24),

                      // Services
                      _SectionTitle(title: 'Services'),
                      const SizedBox(height: AppTheme.spacing8),
                      Wrap(
                        spacing: AppTheme.spacing8,
                        runSpacing: AppTheme.spacing8,
                        children: organization.services.map((service) {
                          return Chip(
                            label: Text(service),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppTheme.spacing24),

                      // Events
                      if (organization.events.isNotEmpty) ...[
                        _SectionTitle(
                          title: 'Upcoming Events',
                          action: TextButton(
                            onPressed: () {
                              // TODO: Navigate to events list
                            },
                            child: const Text('View All'),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: organization.events.length,
                            itemBuilder: (context, index) {
                              final event = organization.events[index];
                              return _EventCard(
                                event: event,
                                onTap: () {
                                  // TODO: Navigate to event details
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                      ],

                      // Projects
                      if (organization.projects.isNotEmpty) ...[
                        _SectionTitle(
                          title: 'Active Projects',
                          action: TextButton(
                            onPressed: () {
                              // TODO: Navigate to projects list
                            },
                            child: const Text('View All'),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: organization.projects.length,
                          itemBuilder: (context, index) {
                            final project = organization.projects[index];
                            return _ProjectCard(
                              project: project,
                              onTap: () {
                                // TODO: Navigate to project details
                              },
                            );
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                      ],

                      // Donation Section
                      if (organization.donationDetails != null) ...[
                        _SectionTitle(title: 'Support Our Cause'),
                        const SizedBox(height: AppTheme.spacing8),
                        _DonationCard(
                          details: organization.donationDetails!,
                          onDonate: () {
                            // TODO: Navigate to donation screen
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                      ],

                      // Volunteer Section
                      _SectionTitle(title: 'Get Involved'),
                      const SizedBox(height: AppTheme.spacing8),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to volunteer registration
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Become a Volunteer'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                'Error Loading Organization',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing16),
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
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionTitle({
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: AppTheme.spacing16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event['title'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppTheme.spacing4),
                  Text(
                    event['date'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppTheme.spacing4),
                  Text(
                    event['time'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                event['description'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${event['attendees']} attending',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Handle RSVP
                    },
                    child: const Text('RSVP'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project['title'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                project['description'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacing8),
              if (project['progress'] != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radius4),
                        child: LinearProgressIndicator(
                          value: project['progress'].toDouble(),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      '${(project['progress'] * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final Map<String, dynamic> details;
  final VoidCallback onDonate;

  const _DonationCard({
    required this.details,
    required this.onDonate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              details['title'] ?? 'Support Our Mission',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              details['description'] ??
                  'Your donation helps us continue our mission to help animals in need.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacing16),
            if (details['goal'] != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Goal: ${details['goal']}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Raised: ${details['raised']}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radius4),
                child: LinearProgressIndicator(
                  value: details['raised'] / details['goal'],
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
            ],
            ElevatedButton(
              onPressed: onDonate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Donate Now'),
            ),
          ],
        ),
      ),
    );
  }
}
