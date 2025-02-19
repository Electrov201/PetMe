import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/veterinary_model.dart';

class VeterinaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'veterinaries';

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<void> addVeterinary(VeterinaryModel veterinary) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      // Add to global veterinaries collection
      await _firestore
          .collection(_collection)
          .doc(veterinary.id)
          .set(veterinary.toMap());

      // Add reference to user's veterinaries
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('veterinary')
          .doc(veterinary.id)
          .set(veterinary.toMap());
    } catch (e) {
      throw Exception('Failed to add veterinary: $e');
    }
  }

  Future<List<VeterinaryModel>> getVeterinaries() async {
    try {
      final snapshot = await _firestore.collection('veterinaries').get();

      return snapshot.docs
          .map((doc) => VeterinaryModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get veterinaries: $e');
    }
  }

  Future<VeterinaryModel?> getVeterinaryById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return VeterinaryModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get veterinary: $e');
    }
  }

  Future<void> updateVeterinary(VeterinaryModel veterinary) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(veterinary.id)
          .update(veterinary.toMap());
    } catch (e) {
      throw Exception('Failed to update veterinary: $e');
    }
  }

  Future<void> deleteVeterinary(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete veterinary: $e');
    }
  }

  Stream<List<VeterinaryModel>> getAvailableVeterinaries() {
    return _firestore
        .collection('veterinaries')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
                (doc) => VeterinaryModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<List<VeterinaryModel>> getVeterinariesBySpecialty(
    String specialty,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('specialties', arrayContains: specialty)
          .where('isVerified', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => VeterinaryModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get veterinaries by specialty: $e');
    }
  }
}
