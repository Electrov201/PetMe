import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/rescue_request_model.dart';

class RescueRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> _uploadImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      final fileName =
          'rescue_requests/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child(fileName);
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploaded': DateTime.now().toIso8601String()},
      );
      final uploadTask = await ref.putFile(imageFile, metadata);

      if (uploadTask.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        throw Exception('Failed to upload image: ${uploadTask.state}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw as this is a cleanup operation
    }
  }

  Future<DocumentReference> addRescueRequest(RescueRequest request,
      {File? imageFile}) async {
    DocumentReference? docRef;
    String? uploadedImageUrl;

    try {
      if (imageFile != null) {
        uploadedImageUrl = await _uploadImage(imageFile);
      }

      final requestData = request
          .copyWith(
            imageUrl: uploadedImageUrl ?? '',
            createdAt: DateTime.now(),
          )
          .toFirestore();

      docRef = await _firestore.collection('rescueRequests').add(requestData);

      // Update the document with its ID
      await docRef.update({'id': docRef.id});

      return docRef;
    } catch (e) {
      // If document was created but update failed, try to delete it
      if (docRef != null) {
        try {
          await docRef.delete();
        } catch (_) {
          // Ignore cleanup errors
        }
      }

      // If image was uploaded but document creation failed, delete it
      if (uploadedImageUrl != null) {
        try {
          await _deleteImage(uploadedImageUrl);
        } catch (_) {
          // Ignore cleanup errors
        }
      }

      throw Exception('Failed to create rescue request: $e');
    }
  }

  Future<List<RescueRequest>> getRescueRequests() async {
    try {
      final snapshot = await _firestore
          .collection('rescueRequests')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => RescueRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rescue requests: $e');
    }
  }

  Future<RescueRequest?> getRescueRequestById(String id) async {
    try {
      final snapshot =
          await _firestore.collection('rescueRequests').doc(id).get();
      if (!snapshot.exists) return null;
      return RescueRequest.fromFirestore(snapshot);
    } catch (e) {
      throw Exception('Failed to fetch rescue request: $e');
    }
  }

  Future<void> updateRescueRequest(RescueRequest request,
      {File? newImageFile}) async {
    String? newImageUrl;

    try {
      if (newImageFile != null) {
        newImageUrl = await _uploadImage(newImageFile);

        // Only delete old image after successful upload of new one
        if (request.imageUrl.isNotEmpty) {
          await _deleteImage(request.imageUrl);
        }
      }

      final requestData = request
          .copyWith(
            imageUrl: newImageUrl ?? request.imageUrl,
          )
          .toFirestore();

      await _firestore
          .collection('rescueRequests')
          .doc(request.id)
          .update(requestData);
    } catch (e) {
      // If new image was uploaded but update failed, delete it
      if (newImageUrl != null) {
        try {
          await _deleteImage(newImageUrl);
        } catch (_) {
          // Ignore cleanup errors
        }
      }
      throw Exception('Failed to update rescue request: $e');
    }
  }

  Future<void> deleteRescueRequest(String id) async {
    try {
      final docRef = _firestore.collection('rescueRequests').doc(id);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Request does not exist');
      }

      final request = RescueRequest.fromFirestore(doc);

      // Use transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        transaction.delete(docRef);
      });

      // Only delete image after successful document deletion
      if (request.imageUrl.isNotEmpty) {
        await _deleteImage(request.imageUrl);
      }
    } catch (e) {
      throw Exception('Failed to delete rescue request: $e');
    }
  }

  Future<void> markAsDone(String requestId, String handledBy) async {
    try {
      final docRef = _firestore.collection('rescueRequests').doc(requestId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Request does not exist');
        }

        if (snapshot.data()?['isDone'] == true) {
          throw Exception('Request is already marked as done');
        }

        transaction.update(docRef, {
          'isDone': true,
          'handledBy': handledBy,
          'completedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to mark request as done: $e');
    }
  }

  Future<void> markAsUndone(String requestId) async {
    try {
      final docRef = _firestore.collection('rescueRequests').doc(requestId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Request does not exist');
        }

        if (snapshot.data()?['isDone'] != true) {
          throw Exception('Request is not marked as done');
        }

        transaction.update(docRef, {
          'isDone': false,
          'handledBy': null,
          'completedAt': null,
        });
      });
    } catch (e) {
      throw Exception('Failed to mark request as undone: $e');
    }
  }
}
