import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/organization_model.dart';
import '../services/organization_service.dart';

class OrganizationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'organizations';
  final OrganizationService _organizationService;

  OrganizationRepository(this._organizationService);

  // Create organization
  Future<void> createOrganization(OrganizationModel organization) async {
    return _organizationService.createOrganization(organization);
  }

  // Get all organizations
  Stream<QuerySnapshot> getAllOrganizations() {
    return _firestore.collection(_collection).snapshots();
  }

  // Get organization by ID
  Future<OrganizationModel?> getOrganizationById(String id) async {
    return _organizationService.getOrganizationById(id);
  }

  // Update organization
  Future<void> updateOrganization(OrganizationModel organization) async {
    return _organizationService.updateOrganization(organization);
  }

  // Delete organization
  Future<void> deleteOrganization(String id) async {
    return _organizationService.deleteOrganization(id);
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

  // Get nearby organizations
  Future<List<OrganizationModel>> getNearbyOrganizations(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    return _organizationService.getNearbyOrganizations(
      latitude,
      longitude,
      radiusInKm,
    );
  }

  // Get user's organizations
  Future<List<OrganizationModel>> getUserOrganizations() async {
    return _organizationService.getUserOrganizations();
  }

  // Stream organization updates
  Stream<OrganizationModel?> streamOrganization(String id) {
    return _organizationService.streamOrganization(id);
  }

  // Add event to organization
  Future<void> addEvent(String orgId, Map<String, dynamic> event) async {
    return _organizationService.addEvent(orgId, event);
  }

  // Add project to organization
  Future<void> addProject(String orgId, Map<String, dynamic> project) async {
    return _organizationService.addProject(orgId, project);
  }

  // Update donation details
  Future<void> updateDonationDetails(
    String orgId,
    Map<String, dynamic> details,
  ) async {
    return _organizationService.updateDonationDetails(orgId, details);
  }
}
