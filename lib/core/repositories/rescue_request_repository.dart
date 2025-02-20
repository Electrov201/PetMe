import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rescue_request_model.dart';
import '../services/rescue_request_service.dart';

class RescueRequestRepository {
  final RescueRequestService _rescueService;

  RescueRequestRepository(this._rescueService);

  Future<DocumentReference> createRescueRequest(RescueRequest request,
      {File? imageFile}) async {
    return _rescueService.addRescueRequest(request, imageFile: imageFile);
  }

  Future<List<RescueRequest>> getAllRescueRequests() async {
    return _rescueService.getRescueRequests();
  }

  Future<RescueRequest?> getRescueRequestById(String id) async {
    return _rescueService.getRescueRequestById(id);
  }

  Future<void> updateRescueRequest(RescueRequest request,
      {File? newImageFile}) async {
    return _rescueService.updateRescueRequest(request,
        newImageFile: newImageFile);
  }

  Future<void> deleteRescueRequest(String id) async {
    return _rescueService.deleteRescueRequest(id);
  }

  Future<void> markRequestAsDone(String requestId, String handledBy) async {
    return _rescueService.markAsDone(requestId, handledBy);
  }

  Future<void> markRequestAsUndone(String requestId) async {
    return _rescueService.markAsUndone(requestId);
  }

  Future<List<RescueRequest>> getNearbyRescueRequests(
      double lat, double lng, double radiusInKm) async {
    final allRequests = await _rescueService.getRescueRequests();

    // Calculate distance for each request and filter by radius
    return allRequests.where((request) {
      final distance = _calculateDistance(
        lat1: lat,
        lon1: lng,
        lat2: request.latitude,
        lon2: request.longitude,
      );
      return distance <= radiusInKm;
    }).toList();
  }

  // Haversine formula to calculate distance between two points
  double _calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadius = 6371; // Radius of the earth in km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = (sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));

    final double c = 2 * asin(sqrt(a));
    return earthRadius * c; // Distance in km
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
