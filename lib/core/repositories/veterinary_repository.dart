import 'dart:math' show asin, cos, pi, pow, sin, sqrt;
import '../models/veterinary_model.dart';
import '../services/veterinary_service.dart';

class VeterinaryRepository {
  final VeterinaryService _veterinaryService;

  VeterinaryRepository(this._veterinaryService);

  // Create veterinary
  Future<void> createVeterinary(VeterinaryModel veterinary) async {
    return _veterinaryService.addVeterinary(veterinary);
  }

  // Get all veterinaries
  Future<List<VeterinaryModel>> getAllVeterinaries() async {
    return _veterinaryService.getVeterinaries();
  }

  // Get veterinary by ID
  Future<VeterinaryModel?> getVeterinaryById(String id) async {
    return _veterinaryService.getVeterinaryById(id);
  }

  // Update veterinary
  Future<void> updateVeterinary(VeterinaryModel veterinary) async {
    return _veterinaryService.updateVeterinary(veterinary);
  }

  // Delete veterinary
  Future<void> deleteVeterinary(String id) async {
    return _veterinaryService.deleteVeterinary(id);
  }

  // Get nearby veterinaries
  Future<List<VeterinaryModel>> getNearbyVeterinaries(
    double lat,
    double lng,
    double radiusInKm,
  ) async {
    final allVets = await _veterinaryService.getVeterinaries();
    return allVets.where((vet) {
      final distance = _calculateDistance(
        lat,
        lng,
        vet.latitude,
        vet.longitude,
      );
      return distance <= radiusInKm;
    }).toList();
  }

  /// Calculates the great-circle distance between two points on Earth
  /// using the Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert latitude and longitude to radians
    final double lat1Rad = _degreesToRadians(lat1);
    final double lon1Rad = _degreesToRadians(lon1);
    final double lat2Rad = _degreesToRadians(lat2);
    final double lon2Rad = _degreesToRadians(lon2);

    // Calculate differences
    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;

    // Haversine formula
    final double a = pow(sin(dLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);
    final double c = 2 * asin(sqrt(a));

    // Calculate distance
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Get available veterinaries
  Stream<List<VeterinaryModel>> getAvailableVeterinaries() {
    return _veterinaryService.getAvailableVeterinaries();
  }
}
