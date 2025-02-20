import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/organization_model.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/app_theme.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late final MapController _mapController;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = true;
  List<OrganizationModel> _organizations = [];
  final double _defaultZoom = 13.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
    _loadOrganizations();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _moveMap(LatLng position, double zoom) async {
    try {
      await _mapController.move(position, zoom);
    } catch (e) {
      // Handle controller error silently
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressComponents = [];

        // Add each component only if it's not null and not empty
        if (place.street != null && place.street!.trim().isNotEmpty) {
          addressComponents.add(place.street!.trim());
        }
        if (place.subLocality != null && place.subLocality!.trim().isNotEmpty) {
          addressComponents.add(place.subLocality!.trim());
        }
        if (place.locality != null && place.locality!.trim().isNotEmpty) {
          addressComponents.add(place.locality!.trim());
        }
        if (place.postalCode != null && place.postalCode!.trim().isNotEmpty) {
          addressComponents.add(place.postalCode!.trim());
        }

        String address = '';
        if (addressComponents.isNotEmpty) {
          address = addressComponents.join(', ');
        }

        // If no valid address components were found, use coordinates
        if (address.isEmpty) {
          address = _formatCoordinates(position);
        }

        if (mounted) {
          setState(() => _currentAddress = address);
        }
      } else {
        // Fallback to coordinates if no placemark found
        if (mounted) {
          setState(() => _currentAddress = _formatCoordinates(position));
        }
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      // Fallback to coordinates on error
      if (mounted) {
        setState(() => _currentAddress = _formatCoordinates(position));
      }
    }
  }

  String _formatCoordinates(Position position) {
    return 'Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}';
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
        await _moveMap(
          LatLng(position.latitude, position.longitude),
          _defaultZoom,
        );
        await _getAddressFromLatLng(position);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadOrganizations() async {
    try {
      final organizationService = ref.read(organizationServiceProvider);
      final organizations =
          await organizationService.streamOrganizations().first;
      if (mounted) {
        setState(() => _organizations = organizations);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading organizations: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentPosition = _currentPosition;
    if (currentPosition == null) {
      return const Scaffold(
        body: Center(child: Text('Unable to get location')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Map'),
            if (_currentAddress != null)
              Text(
                _currentAddress!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter:
              LatLng(currentPosition.latitude, currentPosition.longitude),
          initialZoom: _defaultZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.petme.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point:
                    LatLng(currentPosition.latitude, currentPosition.longitude),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.my_location,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
              ..._organizations.map(
                (org) => Marker(
                  width: 40.0,
                  height: 40.0,
                  point: LatLng(org.latitude, org.longitude),
                  child: GestureDetector(
                    onTap: () => _showOrganizationDetails(org),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pets,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoomIn',
            onPressed: () {
              final currentZoom = _mapController.zoom;
              _moveMap(_mapController.center, currentZoom + 1);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'zoomOut',
            onPressed: () {
              final currentZoom = _mapController.zoom;
              _moveMap(_mapController.center, currentZoom - 1);
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'myLocation',
            onPressed: () {
              if (_currentPosition != null) {
                _moveMap(
                  LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude),
                  _defaultZoom,
                );
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  void _showOrganizationDetails(OrganizationModel organization) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              organization.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              organization.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    context.pop();
                    context.push('/organizations/${organization.id}');
                  },
                  icon: const Icon(Icons.info),
                  label: const Text('Details'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement directions
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement contact
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Contact'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
