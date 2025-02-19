import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/models/feeding_point_model.dart';
import '../../../core/repositories/feeding_point_repository.dart';
import '../../../core/models/pet_model.dart';
import '../../../core/repositories/pet_repository.dart';
import '../../../core/models/veterinary_model.dart';
import '../../../core/repositories/veterinary_repository.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers/providers.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  String _selectedFilter = 'all';
  final double _searchRadius = 10; // in kilometers
  List<Marker> _markers = [];

  late final FeedingPointRepository _feedingPointRepo;
  late final PetRepository _petRepo;
  late final VeterinaryRepository _vetRepo;

  @override
  void initState() {
    super.initState();
    _feedingPointRepo = ref.read(feedingPointRepositoryProvider);
    _petRepo = ref.read(petRepositoryProvider);
    _vetRepo = ref.read(veterinaryRepositoryProvider);
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _goToUserLocation();
      _loadNearbyLocations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Please grant location permission to use the map features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _goToUserLocation() async {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        AppConfig.defaultZoomLevel,
      );
    }
  }

  Future<void> _loadNearbyLocations() async {
    if (_currentPosition == null) return;

    setState(() => _markers = []);

    if (_selectedFilter == 'all' || _selectedFilter == 'pets') {
      await _loadNearbyPets();
    }
    if (_selectedFilter == 'all' || _selectedFilter == 'vets') {
      await _loadNearbyVeterinaries();
    }
    if (_selectedFilter == 'all' || _selectedFilter == 'feedingPoints') {
      await _loadNearbyFeedingPoints();
    }
  }

  Future<void> _loadNearbyPets() async {
    try {
      final pets = await _petRepo.getNearbyPets(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _searchRadius,
      );

      setState(() {
        _markers.addAll(pets.map((pet) => Marker(
              point: LatLng(pet.latitude, pet.longitude),
              child: Material(
                color: Colors.blue.withOpacity(0.7),
                child: InkWell(
                  onTap: () => _showPetDetails(pet),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        const Icon(Icons.pets, color: Colors.white, size: 20),
                  ),
                ),
              ),
            )));
      });
    } catch (e) {
      _showError('Error loading pets: $e');
    }
  }

  Future<void> _loadNearbyVeterinaries() async {
    try {
      final vets = await _vetRepo.getNearbyVeterinaries(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _searchRadius,
      );

      setState(() {
        _markers.addAll(vets.map((vet) => Marker(
              point: LatLng(vet.latitude, vet.longitude),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showVetDetails(vet),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.local_hospital,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            )));
      });
    } catch (e) {
      _showError('Error loading veterinaries: $e');
    }
  }

  Future<void> _loadNearbyFeedingPoints() async {
    try {
      final points = await _feedingPointRepo.getNearbyFeedingPoints(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _searchRadius,
      );

      setState(() {
        _markers.addAll(points.map((point) => Marker(
              point: LatLng(point.latitude, point.longitude),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showFeedingPointDetails(point),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.restaurant,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            )));
      });
    } catch (e) {
      _showError('Error loading feeding points: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showPetDetails(PetModel pet) {
    context.go('/home/profile/my-pets/${pet.id}');
  }

  void _showVetDetails(VeterinaryModel vet) {
    context.go('/home/veterinaries/${vet.id}');
  }

  void _showFeedingPointDetails(FeedingPointModel point) {
    context.go('/home/feeding-points/${point.id}');
  }

  void _addNewLocation() {
    if (_currentPosition == null) {
      _showError('Please enable location services to add a new point');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Add Pet'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home/profile/my-pets/add');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_hospital),
              title: const Text('Add Veterinary'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home/veterinaries/add');
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('Add Feeding Point'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home/feeding-points/add');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services),
            onPressed: () => Navigator.pushNamed(context, '/health-prediction'),
            tooltip: 'Health Prediction',
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToUserLocation,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedFilter = value);
              _loadNearbyLocations();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'all', child: Text('Show All')),
              const PopupMenuItem(value: 'pets', child: Text('Show Pets')),
              const PopupMenuItem(
                value: 'vets',
                child: Text('Show Veterinaries'),
              ),
              const PopupMenuItem(
                value: 'feedingPoints',
                child: Text('Show Feeding Points'),
              ),
            ],
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentPosition != null
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : LatLng(
                  AppConfig.defaultLocationLat, AppConfig.defaultLocationLon),
          initialZoom: AppConfig.defaultZoomLevel,
          onTap: (_, __) => _hideAllInfoWindows(),
        ),
        children: [
          TileLayer(
            urlTemplate: AppConfig.osmTileLayerUrl,
            userAgentPackageName: AppConfig.appName,
          ),
          MarkerLayer(markers: _markers),
          if (_currentPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.my_location,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewLocation,
        child: const Icon(Icons.add_location),
      ),
    );
  }

  void _hideAllInfoWindows() {
    // Implement if you add info windows
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
