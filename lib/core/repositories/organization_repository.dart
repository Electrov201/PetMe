import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationRepository {
	final FirebaseFirestore _firestore = FirebaseFirestore.instance;
	final String _collection = 'organizations';

	// Create organization
	Future<void> createOrganization(Map<String, dynamic> organization) async {
		try {
			await _firestore.collection(_collection).add(organization);
		} catch (e) {
			throw Exception('Failed to create organization: $e');
		}
	}

	// Get all organizations
	Stream<QuerySnapshot> getAllOrganizations() {
		return _firestore.collection(_collection).snapshots();
	}

	// Get organization by ID
	Future<DocumentSnapshot> getOrganizationById(String id) {
		return _firestore.collection(_collection).doc(id).get();
	}

	// Update organization
	Future<void> updateOrganization(String id, Map<String, dynamic> data) async {
		try {
			await _firestore.collection(_collection).doc(id).update(data);
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

	// Get verified organizations
	Stream<QuerySnapshot> getVerifiedOrganizations() {
		return _firestore
				.collection(_collection)
				.where('isVerified', isEqualTo: true)
				.snapshots();
	}

	// Get organizations by type
	Stream<QuerySnapshot> getOrganizationsByType(String type) {
		return _firestore
				.collection(_collection)
				.where('type', isEqualTo: type)
				.snapshots();
	}
}