import '../models/rescue_request_model.dart';
import '../services/rescue_request_service.dart';

class RescueRequestRepository {
  final RescueRequestService _rescueService;

  RescueRequestRepository(this._rescueService);

  Future<void> createRescueRequest(RescueRequestModel request) async {
    return _rescueService.addRescueRequest(request);
  }

  Future<List<RescueRequestModel>> getAllRescueRequests() async {
    return _rescueService.getRescueRequests();
  }

  Future<RescueRequestModel?> getRescueRequestById(String id) async {
    return _rescueService.getRescueRequestById(id);
  }

  Future<void> updateRescueRequest(RescueRequestModel request) async {
    return _rescueService.updateRescueRequest(request);
  }

  Future<void> deleteRescueRequest(String id) async {
    return _rescueService.deleteRescueRequest(id);
  }

  Future<List<RescueRequestModel>> getNearbyRescueRequests(
      double lat, double lng, double radiusInKm) async {
    final allRequests = await _rescueService.getRescueRequests();
    // TODO: Implement geolocation filtering
    return allRequests;
  }

  Future<List<RescueRequestModel>> getEmergencyRescueRequests() async {
    final allRequests = await _rescueService.getRescueRequests();
    return allRequests
        .where((request) =>
            request.emergencyLevel == EmergencyLevel.critical ||
            request.emergencyLevel == EmergencyLevel.high)
        .toList();
  }
}
