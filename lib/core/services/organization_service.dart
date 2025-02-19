import 'dart:math' show asin, cos, pi, pow, sin, sqrt;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/organization_model.dart';

class OrganizationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'organizations';

  // Create organization
  Future<void> createOrganization(OrganizationModel organization) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(organization.id)
          .set(organization.toMap());
    } catch (e) {
      throw Exception('Failed to create organization: $e');
    }
  }

  // Get all organizations
  Stream<List<OrganizationModel>> streamOrganizations() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                OrganizationModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get organization by ID
  Future<OrganizationModel?> getOrganizationById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return OrganizationModel.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to get organization: $e');
    }
  }

  // Update organization
  Future<void> updateOrganization(OrganizationModel organization) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(organization.id)
          .update(organization.toMap());
    } catch (e) {
      throw Exception('Failed to update organization: $e');
    }
  }

  // Delete organization
  Future<void> deleteOrganization(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete organization: $e');
    }
  }

  // Share organization
  Future<void> shareOrganization(String organizationId, String userId) async {
    try {
      final orgRef = _firestore.collection(_collection).doc(organizationId);

      await _firestore.runTransaction((transaction) async {
        final orgDoc = await transaction.get(orgRef);
        if (!orgDoc.exists) {
          throw Exception('Organization not found');
        }

        final currentSharedBy =
            List<String>.from(orgDoc.data()!['sharedBy'] ?? []);
        if (!currentSharedBy.contains(userId)) {
          transaction.update(orgRef, {
            'sharedBy': FieldValue.arrayUnion([userId]),
            'shareCount': FieldValue.increment(1),
            'stats.shares': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to share organization: $e');
    }
  }

  // Report organization
  Future<void> reportOrganization(
    String organizationId,
    String userId,
    String reason,
  ) async {
    try {
      final orgRef = _firestore.collection(_collection).doc(organizationId);
      final reportRef = orgRef.collection('reports').doc();

      await _firestore.runTransaction((transaction) async {
        final orgDoc = await transaction.get(orgRef);
        if (!orgDoc.exists) {
          throw Exception('Organization not found');
        }

        final currentReportedBy =
            List<String>.from(orgDoc.data()!['reportedBy'] ?? []);
        if (!currentReportedBy.contains(userId)) {
          transaction.update(orgRef, {
            'reportedBy': FieldValue.arrayUnion([userId]),
            'reportCount': FieldValue.increment(1),
            'stats.reports': FieldValue.increment(1),
          });

          transaction.set(reportRef, {
            'userId': userId,
            'reason': reason,
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'pending',
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to report organization: $e');
    }
  }

  // Get organization posts
  Stream<QuerySnapshot> streamOrganizationPosts(String organizationId) {
    return _firestore
        .collection(_collection)
        .doc(organizationId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Create organization post
  Future<void> createOrganizationPost(
    String organizationId,
    Map<String, dynamic> post,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(organizationId)
          .collection('posts')
          .add({
        ...post,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'shares': 0,
        'comments': 0,
      });
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Delete organization post
  Future<void> deleteOrganizationPost(
    String organizationId,
    String postId,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(organizationId)
          .collection('posts')
          .doc(postId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Update organization post
  Future<void> updateOrganizationPost(
    String organizationId,
    String postId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(organizationId)
          .collection('posts')
          .doc(postId)
          .update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // Get verified organizations
  Stream<List<OrganizationModel>> streamVerifiedOrganizations() {
    return _firestore
        .collection(_collection)
        .where('verificationStatus',
            isEqualTo: OrganizationVerificationStatus.verified
                .toString()
                .split('.')
                .last)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                OrganizationModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get organizations by type
  Stream<List<OrganizationModel>> streamOrganizationsByType(
      OrganizationType type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type.toString().split('.').last)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                OrganizationModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Search organizations
  Future<List<OrganizationModel>> searchOrganizations(String query) async {
    try {
      // Note: For better search functionality, consider using Algolia or a similar service
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final organizations = snapshot.docs
          .map(
              (doc) => OrganizationModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      return organizations.where((org) {
        final searchableText =
            '${org.name} ${org.description} ${org.tags.join(' ')}'
                .toLowerCase();
        return searchableText.contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Failed to search organizations: $e');
    }
  }

  // Get nearby organizations
  Future<List<OrganizationModel>> getNearbyOrganizations(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    try {
      // Note: For proper geoqueries, consider using a solution like GeoFlutterFire
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final organizations = snapshot.docs
          .map(
              (doc) => OrganizationModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      return organizations.where((org) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          org.latitude,
          org.longitude,
        );
        return distance <= radiusInKm;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get nearby organizations: $e');
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));
    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
