import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final List<String>? favoritePets;
  final List<String>? ownedPets;
  final Timestamp? createdAt;
  final Map<String, dynamic>? preferences;
  final DateTime createdAtDateTime;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.favoritePets,
    this.ownedPets,
    this.createdAt,
    this.preferences,
    required this.createdAtDateTime,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'favoritePets': favoritePets,
      'ownedPets': ownedPets,
      'createdAt': createdAt,
      'preferences': preferences,
      'createdAtDateTime': createdAtDateTime.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      favoritePets: json['favoritePets'] != null
          ? List<String>.from(json['favoritePets'])
          : null,
      ownedPets: json['ownedPets'] != null
          ? List<String>.from(json['ownedPets'])
          : null,
      createdAt: json['createdAt'] as Timestamp?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAtDateTime: DateTime.parse(json['createdAtDateTime'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    List<String>? favoritePets,
    List<String>? ownedPets,
    Timestamp? createdAt,
    Map<String, dynamic>? preferences,
    DateTime? createdAtDateTime,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      favoritePets: favoritePets ?? this.favoritePets,
      ownedPets: ownedPets ?? this.ownedPets,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      createdAtDateTime: createdAtDateTime ?? this.createdAtDateTime,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toDate().toIso8601String(),
      'preferences': preferences,
      'createdAtDateTime': createdAtDateTime.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      photoUrl: map['photoUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      favoritePets: map['favoritePets'] != null
          ? List<String>.from(map['favoritePets'])
          : null,
      ownedPets:
          map['ownedPets'] != null ? List<String>.from(map['ownedPets']) : null,
      createdAt: map['createdAt'] != null
          ? Timestamp.fromDate(DateTime.parse(map['createdAt'] as String))
          : null,
      preferences: map['preferences'] as Map<String, dynamic>?,
      createdAtDateTime: DateTime.parse(map['createdAtDateTime'] as String),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}
