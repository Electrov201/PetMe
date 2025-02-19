import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_model.dart';
import '../services/donation_service.dart';

class DonationRepository {
  final DonationService _donationService;

  DonationRepository(this._donationService);

  // Create a new donation
  Future<void> createDonation(Map<String, dynamic> donationData) async {
    try {
      await _donationService.createDonation(donationData);
    } catch (e) {
      throw Exception('Failed to create donation: $e');
    }
  }

  // Get user's donations
  Stream<QuerySnapshot> getUserDonations() {
    try {
      return _donationService.getUserDonations();
    } catch (e) {
      throw Exception('Failed to get user donations: $e');
    }
  }

  // Get donation by ID
  Future<DocumentSnapshot> getDonationById(String donationId) async {
    try {
      return await _donationService.getDonationById(donationId);
    } catch (e) {
      throw Exception('Failed to get donation: $e');
    }
  }

  // Update donation status
  Future<void> updateDonationStatus(String donationId, String status) async {
    try {
      await _donationService.updateDonationStatus(donationId, status);
    } catch (e) {
      throw Exception('Failed to update donation status: $e');
    }
  }

  // Delete donation
  Future<void> deleteDonation(String donationId) async {
    try {
      await _donationService.deleteDonation(donationId);
    } catch (e) {
      throw Exception('Failed to delete donation: $e');
    }
  }

  // Get donations for a specific pet
  Stream<QuerySnapshot> getPetDonations(String petId) {
    try {
      return _donationService.getPetDonations(petId);
    } catch (e) {
      throw Exception('Failed to get pet donations: $e');
    }
  }

  // Get donations by organization
  Future<List<DonationModel>> getOrganizationDonations(
      String organizationId) async {
    try {
      return await _donationService.getOrganizationDonations(organizationId);
    } catch (e) {
      throw Exception('Failed to get organization donations: $e');
    }
  }

  // Get donation statistics
  Future<Map<String, dynamic>> getDonationStats(String organizationId) async {
    try {
      return await _donationService.getDonationStats(organizationId);
    } catch (e) {
      throw Exception('Failed to get donation statistics: $e');
    }
  }

  // Verify donation
  Future<void> verifyDonation(String donationId) async {
    try {
      await _donationService.verifyDonation(donationId);
    } catch (e) {
      throw Exception('Failed to verify donation: $e');
    }
  }
}
