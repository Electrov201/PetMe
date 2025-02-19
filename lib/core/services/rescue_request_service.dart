import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rescue_request_model.dart';
import 'package:uuid/uuid.dart';

class RescueRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  Future<void> addRescueRequest(RescueRequestModel rescueRequest) async {
    try {
      await _firestore
          .collection('rescueRequests')
          .doc(rescueRequest.id)
          .set(rescueRequest.toJson());
    } catch (e) {
      throw Exception('Failed to add rescue request: $e');
    }
  }

  Future<List<RescueRequestModel>> getRescueRequests() async {
    try {
      final snapshot = await _firestore.collection('rescueRequests').get();
      return snapshot.docs
          .map((doc) => RescueRequestModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rescue requests: $e');
    }
  }

  Future<RescueRequestModel?> getRescueRequestById(String id) async {
    try {
      final snapshot =
          await _firestore.collection('rescueRequests').doc(id).get();
      if (!snapshot.exists) return null;
      return RescueRequestModel.fromMap(snapshot.data()!);
    } catch (e) {
      throw Exception('Failed to fetch rescue request: $e');
    }
  }

  Future<void> updateRescueRequest(RescueRequestModel rescueRequest) async {
    try {
      await _firestore
          .collection('rescueRequests')
          .doc(rescueRequest.id)
          .update(rescueRequest.toJson());
    } catch (e) {
      throw Exception('Failed to update rescue request: $e');
    }
  }

  Future<void> deleteRescueRequest(String id) async {
    try {
      await _firestore.collection('rescueRequests').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete rescue request: $e');
    }
  }
}
