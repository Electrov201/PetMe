import 'package:cloud_firestore/cloud_firestore.dart';

class VeterinaryModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final double latitude;
  final double longitude;
  final String? website;
  final List<String> specialties;
  final Map<String, String> workingHours;
  final bool isEmergency;
  final bool isVerified;
  final List<String> images;
  final Map<String, dynamic>? services;
  final Map<String, dynamic>? ratings;

  VeterinaryModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
    this.website,
    required this.specialties,
    required this.workingHours,
    required this.isEmergency,
    required this.isVerified,
    required this.images,
    this.services,
    this.ratings,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'website': website,
      'specialties': specialties,
      'workingHours': workingHours,
      'isEmergency': isEmergency,
      'isVerified': isVerified,
      'images': images,
      'services': services,
      'ratings': ratings,
    };
  }

  factory VeterinaryModel.fromMap(Map<String, dynamic> map) {
    final GeoPoint? geoPoint = map['location'] as GeoPoint?;

    return VeterinaryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      latitude: geoPoint?.latitude ?? map['latitude'] as double,
      longitude: geoPoint?.longitude ?? map['longitude'] as double,
      website: map['website'] as String?,
      specialties: List<String>.from(map['specialties']),
      workingHours: Map<String, String>.from(map['workingHours']),
      isEmergency: map['isEmergency'] as bool,
      isVerified: map['isVerified'] as bool,
      images: List<String>.from(map['images']),
      services: map['services'] as Map<String, dynamic>?,
      ratings: map['ratings'] as Map<String, dynamic>?,
    );
  }
}
