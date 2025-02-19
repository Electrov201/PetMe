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

      // Update in user's pets collection
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .doc(pet.id)
          .update(pet.toMap());

      // Update or remove from global pets collection based on status
      if (pet.status == PetStatus.available) {
        await _firestore.collection('pets').doc(pet.id).set(pet.toMap());
      } else {
        // If pet is no longer available, remove from global collection
        await _firestore.collection('pets').doc(pet.id).delete();
      }
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

  // Stream individual pet updates
  Stream<PetModel?> streamPetById(String userId, String petId) {
    // Create streams for both collections
    final userPetStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(petId)
        .snapshots();

    final globalPetStream =
        _firestore.collection('pets').doc(petId).snapshots();

    // Combine both streams
    return userPetStream.asyncMap((userDoc) async {
      final globalDoc = await globalPetStream.first;

      // If neither document exists, return null
      if (!userDoc.exists && !globalDoc.exists) return null;

      // Prefer user's pet document if it exists
      if (userDoc.exists) {
        return PetModel.fromMap({...userDoc.data()!, 'id': userDoc.id});
      }

      // Fall back to global pet document
      if (globalDoc.exists) {
        return PetModel.fromMap({...globalDoc.data()!, 'id': globalDoc.id});
      }

      return null;
    });
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

  // Social Interactions
  Future<void> toggleLike(String petId) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      final petRef = _firestore.collection('pets').doc(petId);
      final userPetRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .doc(petId);

      return _firestore.runTransaction((transaction) async {
        final petDoc = await transaction.get(petRef);
        final userPetDoc = await transaction.get(userPetRef);

        if (!petDoc.exists && !userPetDoc.exists) {
          throw Exception('Pet not found');
        }

        List<String> likedBy =
            List<String>.from(petDoc.data()?['likedBy'] ?? []);

        if (likedBy.contains(_userId)) {
          likedBy.remove(_userId);
        } else {
          likedBy.add(_userId);
        }

        if (petDoc.exists) {
          transaction.update(petRef, {'likedBy': likedBy});
        }
        if (userPetDoc.exists) {
          transaction.update(userPetRef, {'likedBy': likedBy});
        }
      });
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  Future<void> addComment(String petId, String text) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      final comment = {
        'userId': _userId,
        'text': text,
        'userName': _auth.currentUser?.displayName ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
      };

      final batch = _firestore.batch();
      final userPetRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .doc(petId);

      final globalPetRef = _firestore.collection('pets').doc(petId);

      // Get current comments from user's pet document
      final userPetDoc = await userPetRef.get();
      if (!userPetDoc.exists) {
        final globalPetDoc = await globalPetRef.get();
        if (!globalPetDoc.exists) {
          throw Exception('Pet not found');
        }
      }

      // Get existing comments or initialize empty list
      List<Map<String, dynamic>> comments = [];
      if (userPetDoc.exists && userPetDoc.data()?['comments'] != null) {
        comments = List<Map<String, dynamic>>.from(
            userPetDoc.data()?['comments'] ?? []);
      } else {
        final globalPetDoc = await globalPetRef.get();
        if (globalPetDoc.exists && globalPetDoc.data()?['comments'] != null) {
          comments = List<Map<String, dynamic>>.from(
              globalPetDoc.data()?['comments'] ?? []);
        }
      }

      // Add new comment
      comments.add(comment);

      // Update both documents atomically
      batch.update(userPetRef, {'comments': comments});
      batch.update(globalPetRef, {'comments': comments});

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> incrementShares(String petId) async {
    try {
      final petRef = _firestore.collection('pets').doc(petId);
      final userPetRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('pets')
          .doc(petId);

      return _firestore.runTransaction((transaction) async {
        final petDoc = await transaction.get(petRef);
        final userPetDoc = await transaction.get(userPetRef);

        if (!petDoc.exists && !userPetDoc.exists) {
          throw Exception('Pet not found');
        }

        final currentShares = (petDoc.data()?['shares'] ?? 0) + 1;

        if (petDoc.exists) {
          transaction.update(petRef, {'shares': currentShares});
        }
        if (userPetDoc.exists) {
          transaction.update(userPetRef, {'shares': currentShares});
        }
      });
    } catch (e) {
      throw Exception('Failed to increment shares: $e');
    }
  }
}
