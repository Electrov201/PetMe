import 'package:cloud_firestore/cloud_firestore.dart';

class RescueRequest {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final bool isDone;
  final DateTime createdAt;
  final String? handledBy;

  RescueRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    this.isDone = false,
    required this.createdAt,
    this.handledBy,
  });

  factory RescueRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RescueRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      isDone: data['isDone'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      handledBy: data['handledBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
      'handledBy': handledBy,
    };
  }

  RescueRequest copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    bool? isDone,
    DateTime? createdAt,
    String? handledBy,
  }) {
    return RescueRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      handledBy: handledBy ?? this.handledBy,
    );
  }
}
