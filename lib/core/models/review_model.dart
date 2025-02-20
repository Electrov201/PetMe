import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String organizationId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> photos;

  ReviewModel({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.photos = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'photos': photos,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userPhotoUrl: map['userPhotoUrl'] as String?,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      photos: List<String>.from(map['photos'] ?? []),
    );
  }
}
