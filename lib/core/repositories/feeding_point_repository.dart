import '../models/feeding_point_model.dart';
import '../services/feeding_point_service.dart';
import 'dart:math' show asin, cos, pi, pow, sin, sqrt;

class FeedingPointRepository {
  final FeedingPointService _feedingPointService;

  FeedingPointRepository(this._feedingPointService);

  Future<void> addFeedingPoint(FeedingPointModel feedingPoint) async {
    return _feedingPointService.addFeedingPoint(feedingPoint);
  }

  Future<List<FeedingPointModel>> getAllFeedingPoints() async {
    return _feedingPointService.getFeedingPoints();
  }

  Future<FeedingPointModel?> getFeedingPointById(String id) async {
    return _feedingPointService.getFeedingPointById(id);
  }

  Future<void> updateFeedingPoint(FeedingPointModel feedingPoint) async {
    return _feedingPointService.updateFeedingPoint(feedingPoint);
  }

  Future<void> deleteFeedingPoint(String id) async {
    return _feedingPointService.deleteFeedingPoint(id);
  }

  Future<List<FeedingPointModel>> getNearbyFeedingPoints(
    double lat,
    double lng,
    double radiusInKm,
  ) async {
    final allPoints = await _feedingPointService.getFeedingPoints();
    return allPoints.where((point) {
      final distance = _calculateDistance(
        lat,
        lng,
        point.latitude,
        point.longitude,
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
}
