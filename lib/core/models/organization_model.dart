import 'package:cloud_firestore/cloud_firestore.dart';

enum OrganizationType { shelter, rescue, clinic, sanctuary, other }

enum OrganizationVerificationStatus { pending, verified, rejected }

class OrganizationModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String? website;
  final List<String> images;
  final String ownerId;
  final OrganizationType type;
  final OrganizationVerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? services;
  final Map<String, String> socialLinks;
  final List<String> tags;
  final bool isActive;
  final Map<String, dynamic> stats;
  final List<String> reportedBy;
  final List<String> sharedBy;
  final int reportCount;
  final int shareCount;
  final double rating;
  final int reviewCount;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    this.website,
    required this.images,
    required this.ownerId,
    required this.type,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
    this.services,
    required this.socialLinks,
    required this.tags,
    required this.isActive,
    required this.stats,
    required this.reportedBy,
    required this.sharedBy,
    required this.reportCount,
    required this.shareCount,
    required this.rating,
    required this.reviewCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'location': GeoPoint(latitude, longitude),
      'phone': phone,
      'email': email,
      'website': website,
      'images': images,
      'ownerId': ownerId,
      'type': type.toString().split('.').last,
      'verificationStatus': verificationStatus.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'services': services,
      'socialLinks': socialLinks,
      'tags': tags,
      'isActive': isActive,
      'stats': stats,
      'reportedBy': reportedBy,
      'sharedBy': sharedBy,
      'reportCount': reportCount,
      'shareCount': shareCount,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  factory OrganizationModel.fromMap(Map<String, dynamic> map) {
    final location = map['location'] as GeoPoint;

    return OrganizationModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      address: map['address'] as String,
      latitude: location.latitude,
      longitude: location.longitude,
      phone: map['phone'] as String,
      email: map['email'] as String,
      website: map['website'] as String?,
      images: List<String>.from(map['images']),
      ownerId: map['ownerId'] as String,
      type: OrganizationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => OrganizationType.other,
      ),
      verificationStatus: OrganizationVerificationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['verificationStatus'],
        orElse: () => OrganizationVerificationStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      services: map['services'] as Map<String, dynamic>?,
      socialLinks: Map<String, String>.from(map['socialLinks']),
      tags: List<String>.from(map['tags']),
      isActive: map['isActive'] as bool,
      stats: Map<String, dynamic>.from(map['stats']),
      reportedBy: List<String>.from(map['reportedBy']),
      sharedBy: List<String>.from(map['sharedBy']),
      reportCount: map['reportCount'] as int,
      shareCount: map['shareCount'] as int,
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['reviewCount'] as int,
    );
  }

  OrganizationModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    String? email,
    String? website,
    List<String>? images,
    String? ownerId,
    OrganizationType? type,
    OrganizationVerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? services,
    Map<String, String>? socialLinks,
    List<String>? tags,
    bool? isActive,
    Map<String, dynamic>? stats,
    List<String>? reportedBy,
    List<String>? sharedBy,
    int? reportCount,
    int? shareCount,
    double? rating,
    int? reviewCount,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      images: images ?? this.images,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      services: services ?? this.services,
      socialLinks: socialLinks ?? this.socialLinks,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      stats: stats ?? this.stats,
      reportedBy: reportedBy ?? this.reportedBy,
      sharedBy: sharedBy ?? this.sharedBy,
      reportCount: reportCount ?? this.reportCount,
      shareCount: shareCount ?? this.shareCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
