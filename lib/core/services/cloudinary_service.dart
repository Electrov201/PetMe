import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import '../models/media_response.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CloudinaryService() {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
    _cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<MediaResponse> uploadUserProfileImage(File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'petme/users/$_userId/profile',
          publicId: 'profile_${_userId}_$timestamp',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return MediaResponse.fromCloudinary(response.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaResponse> uploadPetImage(String petId, File imageFile,
      {bool isPrimary = false}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final subfolder = isPrimary ? 'primary' : 'gallery';

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'petme/pets/$petId/$subfolder',
          publicId: 'pet_${petId}_${timestamp}_$subfolder',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return MediaResponse.fromCloudinary(response.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaResponse> uploadSingleImage(XFile image) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'petme/uploads',
        ),
      );
      return MediaResponse.fromCloudinary(response.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MediaResponse>> uploadMultipleImages(List<XFile> images) async {
    try {
      final responses = await Future.wait(
        images.map((image) async {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final response = await _cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              image.path,
              folder: 'petme/uploads',
              publicId: 'pet_${_userId}_${timestamp}',
              resourceType: CloudinaryResourceType.Image,
            ),
          );
          return MediaResponse.fromCloudinary(response.toMap());
        }),
      );
      return responses;
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaResponse> uploadRescueImage(
      String requestId, File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'petme/rescue/$requestId',
          publicId: 'rescue_${requestId}_$timestamp',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return MediaResponse.fromCloudinary(response.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaResponse> uploadVetImage(String vetId, File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'petme/veterinary/$vetId',
          publicId: 'vet_${vetId}_$timestamp',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return MediaResponse.fromCloudinary(response.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaResponse> uploadFeedingPointImage(
      String pointId, File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'petme/feeding-points/$pointId',
          publicId: 'feeding_${pointId}_$timestamp',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return MediaResponse.fromCloudinary(response.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaResponse> uploadDonationImage(
      String donationId, File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'petme/donations/$donationId',
          publicId: 'donation_${donationId}_$timestamp',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return MediaResponse.fromCloudinary(response.toMap());
    } catch (e) {
      rethrow;
    }
  }

  String getThumbnailUrl(String originalUrl) {
    return originalUrl.replaceAll(
      'upload/',
      'upload/w_150,h_150,c_fill,g_auto/',
    );
  }

  String getProfilePictureUrl(String originalUrl) {
    return originalUrl.replaceAll(
      'upload/',
      'upload/w_300,h_300,c_fill,g_face/',
    );
  }

  String getGalleryImageUrl(String originalUrl) {
    return originalUrl.replaceAll(
      'upload/',
      'upload/w_800,h_600,c_fill,g_auto/',
    );
  }

  Future<bool> deleteImage(String publicId) async {
    try {
      // Note: Deletion requires admin API access.
      // Consider implementing this on your backend
      throw UnimplementedError(
        'Image deletion should be handled through your backend for security.',
      );
    } catch (e) {
      return false;
    }
  }
}
