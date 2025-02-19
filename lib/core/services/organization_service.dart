import 'dart:math' show asin, cos, pi, pow, sin, sqrt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/organization_model.dart';

class OrganizationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'organizations';

  String get _userId => _auth.currentUser?.uid ?? '';

  // Create organization
  Future<void> createOrganization(OrganizationModel organization) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection(_collection)
          .doc(organization.id)
          .set(organization.toMap());

      // Add to user's organizations
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('organizations')
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
      if (_userId.isEmpty) throw Exception('User not authenticated');

      final batch = _firestore.batch();

      // Update in organizations collection
      batch.update(
        _firestore.collection(_collection).doc(organization.id),
        organization.toMap(),
      );

      // Update in user's organizations collection
      batch.update(
        _firestore
            .collection('users')
            .doc(_userId)
            .collection('organizations')
            .doc(organization.id),
        organization.toMap(),
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update organization: $e');
    }
  }

  // Delete organization
  Future<void> deleteOrganization(String id) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      final batch = _firestore.batch();

      // Delete from organizations collection
      batch.delete(_firestore.collection(_collection).doc(id));

      // Delete from user's organizations collection
      batch.delete(
        _firestore
            .collection('users')
            .doc(_userId)
            .collection('organizations')
            .doc(id),
      );

      await batch.commit();
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
            isEqualTo: VerificationStatus.verified.toString().split('.').last)
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
            '${org.name} ${org.description} ${org.services.join(' ')}'
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
      // Get all organizations (in a real app, you'd use geoqueries)
      final snapshot = await _firestore.collection(_collection).get();

      final organizations = snapshot.docs
          .map(
              (doc) => OrganizationModel.fromMap({...doc.data(), 'id': doc.id}))
          .where((org) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          org.latitude,
          org.longitude,
        );
        return distance <= radiusInKm;
      }).toList();

      // Sort by distance
      organizations.sort((a, b) {
        final distanceA = _calculateDistance(
          latitude,
          longitude,
          a.latitude,
          a.longitude,
        );
        final distanceB = _calculateDistance(
          latitude,
          longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      return organizations;
    } catch (e) {
      throw Exception('Failed to get nearby organizations: $e');
    }
  }

  // Get user's organizations
  Future<List<OrganizationModel>> getUserOrganizations() async {
    try {
      if (_userId.isEmpty) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('organizations')
          .get();

      return snapshot.docs
          .map(
              (doc) => OrganizationModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user organizations: $e');
    }
  }

  // Stream organization updates
  Stream<OrganizationModel?> streamOrganization(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return OrganizationModel.fromMap({...doc.data()!, 'id': doc.id});
    });
  }

  // Add event to organization
  Future<void> addEvent(String orgId, Map<String, dynamic> event) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      final batch = _firestore.batch();
      final eventWithTimestamp = {
        ...event,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add to organizations collection
      batch.update(
        _firestore.collection(_collection).doc(orgId),
        {
          'events': FieldValue.arrayUnion([eventWithTimestamp])
        },
      );

      // Add to user's organizations collection
      batch.update(
        _firestore
            .collection('users')
            .doc(_userId)
            .collection('organizations')
            .doc(orgId),
        {
          'events': FieldValue.arrayUnion([eventWithTimestamp])
        },
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add event: $e');
    }
  }

  // Add project to organization
  Future<void> addProject(String orgId, Map<String, dynamic> project) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      final batch = _firestore.batch();
      final projectWithTimestamp = {
        ...project,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add to organizations collection
      batch.update(
        _firestore.collection(_collection).doc(orgId),
        {
          'projects': FieldValue.arrayUnion([projectWithTimestamp])
        },
      );

      // Add to user's organizations collection
      batch.update(
        _firestore
            .collection('users')
            .doc(_userId)
            .collection('organizations')
            .doc(orgId),
        {
          'projects': FieldValue.arrayUnion([projectWithTimestamp])
        },
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add project: $e');
    }
  }

  // Update donation details
  Future<void> updateDonationDetails(
    String orgId,
    Map<String, dynamic> details,
  ) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      final batch = _firestore.batch();

      // Update in organizations collection
      batch.update(
        _firestore.collection(_collection).doc(orgId),
        {'donationDetails': details},
      );

      // Update in user's organizations collection
      batch.update(
        _firestore
            .collection('users')
            .doc(_userId)
            .collection('organizations')
            .doc(orgId),
        {'donationDetails': details},
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update donation details: $e');
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
