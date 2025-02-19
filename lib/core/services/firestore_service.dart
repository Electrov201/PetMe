import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Operations
  Future<void> createUser(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).set(userData);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).update(userData);
  }

  Future<DocumentSnapshot> getUser(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  Future<void> logUserActivity(
      String userId, Map<String, dynamic> activity) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .add({
      ...activity,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Pet Operations
  Future<String> createPet(Map<String, dynamic> petData) async {
    final docRef = await _firestore.collection('pets').add({
      ...petData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updatePet(String petId, Map<String, dynamic> petData) async {
    await _firestore.collection('pets').doc(petId).update({
      ...petData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getPet(String petId) async {
    return await _firestore.collection('pets').doc(petId).get();
  }

  Stream<QuerySnapshot> getUserPets(String userId) {
    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: userId)
        .snapshots();
  }

  // Rescue Operations
  Future<String> createRescueRequest(Map<String, dynamic> rescueData) async {
    final docRef = await _firestore.collection('rescue_requests').add({
      ...rescueData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateRescueRequest(
      String requestId, Map<String, dynamic> rescueData) async {
    await _firestore.collection('rescue_requests').doc(requestId).update({
      ...rescueData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addRescueUpdate(
      String requestId, Map<String, dynamic> updateData) async {
    await _firestore
        .collection('rescue_requests')
        .doc(requestId)
        .collection('updates')
        .add({
      ...updateData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Veterinary Operations
  Future<String> createVeterinaryService(Map<String, dynamic> vetData) async {
    final docRef = await _firestore.collection('veterinaries').add({
      ...vetData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> createAppointment(
      String vetId, Map<String, dynamic> appointmentData) async {
    await _firestore
        .collection('veterinaries')
        .doc(vetId)
        .collection('appointments')
        .add({
      ...appointmentData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Feeding Point Operations
  Future<String> createFeedingPoint(Map<String, dynamic> pointData) async {
    final docRef = await _firestore.collection('feedingPoints').add({
      ...pointData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateFeedingPoint(
      String pointId, Map<String, dynamic> pointData) async {
    await _firestore.collection('feedingPoints').doc(pointId).update({
      ...pointData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Donation Operations
  Future<String> createDonation(Map<String, dynamic> donationData) async {
    final docRef = await _firestore.collection('donations').add({
      ...donationData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateDonationStatus(String donationId, String status) async {
    await _firestore.collection('donations').doc(donationId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Chat Operations
  Future<String> createChat(List<String> participants) async {
    final docRef = await _firestore.collection('chats').add({
      'participants': participants,
      'type': participants.length > 2 ? 'group' : 'direct',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> sendMessage(
      String chatId, Map<String, dynamic> messageData) async {
    final batch = _firestore.batch();

    // Add message to subcollection
    final messageRef =
        _firestore.collection('chats').doc(chatId).collection('messages').doc();

    batch.set(messageRef, {
      ...messageData,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update chat document with last message
    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': messageData['content'],
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Media Asset Operations
  Future<void> createMediaAsset(Map<String, dynamic> mediaData) async {
    await _firestore.collection('media').add({
      ...mediaData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Query Operations
  Stream<QuerySnapshot> getNearbyPets(GeoPoint center, double radiusInKm) {
    // Note: This is a simplified query. For proper geoqueries,
    // consider using a solution like GeoFlutterFire
    return _firestore
        .collection('pets')
        .where('status', isEqualTo: 'available')
        .snapshots();
  }

  Stream<QuerySnapshot> getNearbyVets(GeoPoint center, double radiusInKm) {
    return _firestore.collection('veterinaries').snapshots();
  }

  Stream<QuerySnapshot> getActiveRescueRequests() {
    return _firestore
        .collection('rescueRequests')
        .where('status', whereIn: ['pending', 'inProgress'])
        .orderBy('urgency', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getNearbyFeedingPoints(
      GeoPoint center, double radiusInKm) {
    return _firestore
        .collection('feedingPoints')
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  // Utility Methods
  String get currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> runTransaction(Function(Transaction) updateFunction) async {
    await _firestore.runTransaction((transaction) async {
      await updateFunction(transaction);
    });
  }

  Future<void> batchWrite(Function(WriteBatch) updateFunction) async {
    final batch = _firestore.batch();
    await updateFunction(batch);
    await batch.commit();
  }
}
