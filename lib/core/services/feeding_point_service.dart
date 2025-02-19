import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feeding_point_model.dart';

class FeedingPointService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'feedingPoints';

  // Add a new feeding point
  Future<void> addFeedingPoint(FeedingPointModel feedingPoint) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(feedingPoint.id)
          .set(feedingPoint.toMap());
    } catch (e) {
      throw Exception('Failed to add feeding point: $e');
    }
  }

  // Get all feeding points
  Future<List<FeedingPointModel>> getFeedingPoints() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedingPointModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get feeding points: $e');
    }
  }

  // Get feeding point by ID
  Future<FeedingPointModel?> getFeedingPointById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return FeedingPointModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get feeding point: $e');
    }
  }

  // Update feeding point
  Future<void> updateFeedingPoint(FeedingPointModel feedingPoint) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(feedingPoint.id)
          .update(feedingPoint.toMap());
    } catch (e) {
      throw Exception('Failed to update feeding point: $e');
    }
  }

  // Delete feeding point
  Future<void> deleteFeedingPoint(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete feeding point: $e');
    }
  }

  // Get nearby feeding points
  Stream<List<FeedingPointModel>> getNearbyFeedingPoints(
    double lat,
    double lng,
    double radiusInKm,
  ) {
    return _firestore.collection(_collection).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => FeedingPointModel.fromMap(doc.data()))
            .toList());
  }

  // Get active feeding points
  Stream<List<FeedingPointModel>> getActiveFeedingPoints() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedingPointModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> updateLastFed(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'lastFed': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update last fed time: $e');
    }
  }

  Future<List<FeedingPointModel>> getFeedingPointsByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('createdBy', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => FeedingPointModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user feeding points: $e');
    }
  }
}
