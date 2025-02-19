import 'package:cloud_firestore/cloud_firestore.dart';

class FeedingPointModel {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String userId;
  final bool isActive;
  final DateTime createdAt;
  final String? imageUrl;
  final Map<String, dynamic>? schedule;
  final List<String>? foodTypes;

  FeedingPointModel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.userId,
    this.isActive = true,
    required this.createdAt,
    this.imageUrl,
    this.schedule,
    this.foodTypes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'schedule': schedule,
      'foodTypes': foodTypes,
    };
  }

  factory FeedingPointModel.fromMap(Map<String, dynamic> map) {
    final GeoPoint? geoPoint = map['location'] as GeoPoint?;

    return FeedingPointModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      latitude: geoPoint?.latitude ?? map['latitude'] as double,
      longitude: geoPoint?.longitude ?? map['longitude'] as double,
      userId: map['userId'] as String,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'] as String?,
      schedule: map['schedule'] as Map<String, dynamic>?,
      foodTypes:
          map['foodTypes'] != null ? List<String>.from(map['foodTypes']) : null,
    );
  }
}
