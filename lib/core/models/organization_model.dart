import 'package:cloud_firestore/cloud_firestore.dart';

enum OrganizationType {
  shelter,
  clinic,
  ngo,
  rescue,
  other,
}

enum VerificationStatus {
  pending,
  verified,
  rejected,
}

class OrganizationModel {
  final String id;
  final String name;
  final String description;
  final String email;
  final String phone;
  final String website;
  final String address;
  final double latitude;
  final double longitude;
  final OrganizationType type;
  final VerificationStatus verificationStatus;
  final String? verificationDocument;
  final List<String> images;
  final String ownerId;
  final List<String> adminIds;
  final Map<String, dynamic> operatingHours;
  final List<String> services;
  final Map<String, dynamic> socialMedia;
  final int rescueCount;
  final int adoptionCount;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? donationDetails;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> projects;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.verificationStatus,
    this.verificationDocument,
    required this.images,
    required this.ownerId,
    required this.adminIds,
    required this.operatingHours,
    required this.services,
    required this.socialMedia,
    this.rescueCount = 0,
    this.adoptionCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.donationDetails,
    this.events = const [],
    this.projects = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'email': email,
      'phone': phone,
      'website': website,
      'address': address,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'type': type.toString().split('.').last,
      'verificationStatus': verificationStatus.toString().split('.').last,
      'verificationDocument': verificationDocument,
      'images': images,
      'ownerId': ownerId,
      'adminIds': adminIds,
      'operatingHours': operatingHours,
      'services': services,
      'socialMedia': socialMedia,
      'rescueCount': rescueCount,
      'adoptionCount': adoptionCount,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'donationDetails': donationDetails,
      'events': events,
      'projects': projects,
    };
  }

  factory OrganizationModel.fromMap(Map<String, dynamic> map) {
    final location = map['location'] as Map<String, dynamic>?;

    return OrganizationModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      website: map['website'] as String,
      address: map['address'] as String,
      latitude: location?['latitude'] as double? ?? 0.0,
      longitude: location?['longitude'] as double? ?? 0.0,
      type: OrganizationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => OrganizationType.other,
      ),
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['verificationStatus'],
        orElse: () => VerificationStatus.pending,
      ),
      verificationDocument: map['verificationDocument'] as String?,
      images: List<String>.from(map['images'] as List<dynamic>),
      ownerId: map['ownerId'] as String,
      adminIds: List<String>.from(map['adminIds'] as List<dynamic>),
      operatingHours: map['operatingHours'] as Map<String, dynamic>,
      services: List<String>.from(map['services'] as List<dynamic>),
      socialMedia: map['socialMedia'] as Map<String, dynamic>,
      rescueCount: map['rescueCount'] as int? ?? 0,
      adoptionCount: map['adoptionCount'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] as bool? ?? true,
      donationDetails: map['donationDetails'] as Map<String, dynamic>?,
      events: List<Map<String, dynamic>>.from(map['events'] ?? []),
      projects: List<Map<String, dynamic>>.from(map['projects'] ?? []),
    );
  }

  OrganizationModel copyWith({
    String? id,
    String? name,
    String? description,
    String? email,
    String? phone,
    String? website,
    String? address,
    double? latitude,
    double? longitude,
    OrganizationType? type,
    VerificationStatus? verificationStatus,
    String? verificationDocument,
    List<String>? images,
    String? ownerId,
    List<String>? adminIds,
    Map<String, dynamic>? operatingHours,
    List<String>? services,
    Map<String, dynamic>? socialMedia,
    int? rescueCount,
    int? adoptionCount,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? donationDetails,
    List<Map<String, dynamic>>? events,
    List<Map<String, dynamic>>? projects,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDocument: verificationDocument ?? this.verificationDocument,
      images: images ?? this.images,
      ownerId: ownerId ?? this.ownerId,
      adminIds: adminIds ?? this.adminIds,
      operatingHours: operatingHours ?? this.operatingHours,
      services: services ?? this.services,
      socialMedia: socialMedia ?? this.socialMedia,
      rescueCount: rescueCount ?? this.rescueCount,
      adoptionCount: adoptionCount ?? this.adoptionCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      donationDetails: donationDetails ?? this.donationDetails,
      events: events ?? this.events,
      projects: projects ?? this.projects,
    );
  }
}
