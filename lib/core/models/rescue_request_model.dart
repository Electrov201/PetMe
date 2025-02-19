import 'package:cloud_firestore/cloud_firestore.dart';

enum EmergencyLevel { low, medium, high, critical }

class RescueRequestModel {
  final String id;
  final String location;
  final String description;
  final EmergencyLevel emergencyLevel;
  final String userId;
  final Timestamp createdAt;

  RescueRequestModel({
    required this.id,
    required this.location,
    required this.description,
    required this.emergencyLevel,
    required this.userId,
    required this.createdAt,
  });

  // Convert to JSON for storing in Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'description': description,
      'emergencyLevel': emergencyLevel.toString(),
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  // Create from map for retrieving from Firestore
  factory RescueRequestModel.fromMap(Map<String, dynamic> map) {
    return RescueRequestModel(
      id: map['id'] as String,
      location: map['location'] as String,
      description: map['description'] as String,
      emergencyLevel: _stringToEmergencyLevel(map['emergencyLevel'] as String),
      userId: map['userId'] as String,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  static EmergencyLevel _stringToEmergencyLevel(String emergencyLevelString) {
    switch (emergencyLevelString) {
      case 'EmergencyLevel.low':
        return EmergencyLevel.low;
      case 'EmergencyLevel.medium':
        return EmergencyLevel.medium;
      case 'EmergencyLevel.high':
        return EmergencyLevel.high;
      case 'EmergencyLevel.critical':
        return EmergencyLevel.critical;
      default:
        return EmergencyLevel.medium;
    }
  }
}
