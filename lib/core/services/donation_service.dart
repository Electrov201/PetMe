import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/donation_model.dart';

class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'donations';

  String get _userId => _auth.currentUser?.uid ?? '';

  // Create a new donation
  Future<void> createDonation(Map<String, dynamic> donationData) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('donations')
          .add({
        ...donationData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create donation: $e');
    }
  }

  // Get user's donations
  Stream<QuerySnapshot> getUserDonations() {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('donations')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get donation by ID
  Future<DocumentSnapshot> getDonationById(String donationId) async {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    return await _firestore
        .collection('users')
        .doc(_userId)
        .collection('donations')
        .doc(donationId)
        .get();
  }

  // Update donation status
  Future<void> updateDonationStatus(String donationId, String status) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('donations')
          .doc(donationId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update donation status: $e');
    }
  }

  // Delete donation
  Future<void> deleteDonation(String donationId) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('donations')
          .doc(donationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete donation: $e');
    }
  }

  // Get donations for a specific pet
  Stream<QuerySnapshot> getPetDonations(String petId) {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('donations')
        .where('petId', isEqualTo: petId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get donations by organization ID
  Future<List<DonationModel>> getOrganizationDonations(
      String organizationId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('organizationId', isEqualTo: organizationId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DonationModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get organization donations: $e');
    }
  }

  // Get donation statistics
  Future<Map<String, dynamic>> getDonationStats(String organizationId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('organizationId', isEqualTo: organizationId)
          .where('isVerified', isEqualTo: true)
          .get();

      final donations = snapshot.docs
          .map((doc) => DonationModel.fromMap(doc.data()))
          .toList();

      double totalAmount = 0;
      for (final donation in donations) {
        totalAmount += donation.amount;
      }

      return {
        'totalDonations': donations.length,
        'totalAmount': totalAmount,
        'lastDonation': donations.isNotEmpty ? donations.first.toMap() : null,
      };
    } catch (e) {
      throw Exception('Failed to get donation stats: $e');
    }
  }

  // Verify donation
  Future<void> verifyDonation(String donationId) async {
    try {
      await _firestore.collection(_collection).doc(donationId).update({
        'isVerified': true,
      });
    } catch (e) {
      throw Exception('Failed to verify donation: $e');
    }
  }
}
