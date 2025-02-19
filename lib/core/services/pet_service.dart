import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pet_model.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Add a new pet
  Future<void> addPet(PetModel pet) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      // Add to user's pets collection
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .doc(pet.id)
          .set(pet.toMap());

      // Add to global pets collection if status is available
      if (pet.status == PetStatus.available) {
        await _firestore.collection('pets').doc(pet.id).set(pet.toMap());
      }
    } catch (e) {
      throw Exception('Failed to add pet: $e');
    }
  }

  // Get all pets for current user
  Future<List<PetModel>> getUserPets() async {
    try {
      if (_userId.isEmpty) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .get();

      return snapshot.docs
          .map((doc) => PetModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pets: $e');
    }
  }

  // Get pet by ID
  Future<PetModel?> getPetById(String userId, String petId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .get();

      if (!doc.exists) return null;
      return PetModel.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to get pet: $e');
    }
  }

  // Update pet
  Future<void> updatePet(PetModel pet) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .doc(pet.id)
          .update(pet.toMap());
    } catch (e) {
      throw Exception('Failed to update pet: $e');
    }
  }

  // Delete pet
  Future<void> deletePet(String petId) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .doc(petId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete pet: $e');
    }
  }

  // Stream user's pets
  Stream<List<PetModel>> streamUserPets(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PetModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get all available pets (across all users)
  Future<List<PetModel>> getAvailablePets() async {
    try {
      // Query global pets collection
      final petsSnapshot = await _firestore
          .collection('pets')
          .where('status',
              isEqualTo: PetStatus.available.toString().split('.').last)
          .get();

      return petsSnapshot.docs
          .map((doc) => PetModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get available pets: $e');
    }
  }

  // Add medical record
  Future<void> addMedicalRecord(
    String petId,
    Map<String, dynamic> medicalRecord,
  ) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .doc(petId)
          .collection('medical')
          .add({
        ...medicalRecord,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add medical record: $e');
    }
  }

  // Stream medical records
  Stream<QuerySnapshot> streamMedicalRecords(String petId) {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('pets')
        .doc(petId)
        .collection('medical')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Update behavior notes
  Future<void> updateBehaviorNotes(
    String petId,
    Map<String, dynamic> behaviorNotes,
  ) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .doc(petId)
          .update({
        'behavior': behaviorNotes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update behavior notes: $e');
    }
  }
}
