import 'package:cloud_firestore/cloud_firestore.dart';

enum PetStatus {
  available,
  adopted,
  fostered,
  underTreatment,
}

class PetModel {
  final String id;
  final String name;
  final String type;
  final String breed;
  final String description;
  final int age;
  final String gender;
  final double latitude;
  final double longitude;
  final String reporterId;
  final String? ownerId;
  final PetStatus status;
  final DateTime reportedAt;
  final List<String> images;
  final Map<String, dynamic>? medicalHistory;
  final Map<String, dynamic>? behavior;

  PetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.description,
    required this.age,
    required this.gender,
    required this.latitude,
    required this.longitude,
    required this.reporterId,
    this.ownerId,
    required this.status,
    required this.reportedAt,
    required this.images,
    this.medicalHistory,
    this.behavior,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'description': description,
      'age': age,
      'gender': gender,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'reporterId': reporterId,
      'ownerId': ownerId,
      'status': status.toString().split('.').last,
      'reportedAt': Timestamp.fromDate(reportedAt),
      'images': images,
      'medicalHistory': medicalHistory,
      'behavior': behavior,
    };
  }

  factory PetModel.fromMap(Map<String, dynamic> map) {
    final location = map['location'] as Map<String, dynamic>?;

    return PetModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      breed: map['breed'] as String,
      description: map['description'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      latitude: location?['latitude'] as double? ?? 0.0,
      longitude: location?['longitude'] as double? ?? 0.0,
      reporterId: map['reporterId'] as String,
      ownerId: map['ownerId'] as String?,
      status: PetStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => PetStatus.available,
      ),
      reportedAt: (map['reportedAt'] as Timestamp).toDate(),
      images: List<String>.from(map['images'] as List<dynamic>),
      medicalHistory: map['medicalHistory'] as Map<String, dynamic>?,
      behavior: map['behavior'] as Map<String, dynamic>?,
    );
  }

  PetModel copyWith({
    String? id,
    String? name,
    String? type,
    String? breed,
    String? description,
    int? age,
    String? gender,
    double? latitude,
    double? longitude,
    String? reporterId,
    String? ownerId,
    PetStatus? status,
    DateTime? reportedAt,
    List<String>? images,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? behavior,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      description: description ?? this.description,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      reporterId: reporterId ?? this.reporterId,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      reportedAt: reportedAt ?? this.reportedAt,
      images: images ?? this.images,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      behavior: behavior ?? this.behavior,
    );
  }
}
