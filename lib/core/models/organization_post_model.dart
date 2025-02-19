import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { announcement, event, fundraiser, adoption, general }

class OrganizationPostModel {
  final String id;
  final String organizationId;
  final String authorId;
  final String title;
  final String content;
  final List<String> images;
  final PostType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;
  final List<String> likedBy;
  final List<String> sharedBy;
  final List<String> reportedBy;
  final int likeCount;
  final int shareCount;
  final int commentCount;
  final int reportCount;
  final bool isActive;

  OrganizationPostModel({
    required this.id,
    required this.organizationId,
    required this.authorId,
    required this.title,
    required this.content,
    required this.images,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
    required this.likedBy,
    required this.sharedBy,
    required this.reportedBy,
    required this.likeCount,
    required this.shareCount,
    required this.commentCount,
    required this.reportCount,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'authorId': authorId,
      'title': title,
      'content': content,
      'images': images,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
      'likedBy': likedBy,
      'sharedBy': sharedBy,
      'reportedBy': reportedBy,
      'likeCount': likeCount,
      'shareCount': shareCount,
      'commentCount': commentCount,
      'reportCount': reportCount,
      'isActive': isActive,
    };
  }

  factory OrganizationPostModel.fromMap(Map<String, dynamic> map) {
    return OrganizationPostModel(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      authorId: map['authorId'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      images: List<String>.from(map['images']),
      type: PostType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => PostType.general,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      metadata: map['metadata'] as Map<String, dynamic>?,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      sharedBy: List<String>.from(map['sharedBy'] ?? []),
      reportedBy: List<String>.from(map['reportedBy'] ?? []),
      likeCount: map['likeCount'] as int? ?? 0,
      shareCount: map['shareCount'] as int? ?? 0,
      commentCount: map['commentCount'] as int? ?? 0,
      reportCount: map['reportCount'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  OrganizationPostModel copyWith({
    String? id,
    String? organizationId,
    String? authorId,
    String? title,
    String? content,
    List<String>? images,
    PostType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    List<String>? likedBy,
    List<String>? sharedBy,
    List<String>? reportedBy,
    int? likeCount,
    int? shareCount,
    int? commentCount,
    int? reportCount,
    bool? isActive,
  }) {
    return OrganizationPostModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      likedBy: likedBy ?? this.likedBy,
      sharedBy: sharedBy ?? this.sharedBy,
      reportedBy: reportedBy ?? this.reportedBy,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount ?? this.shareCount,
      commentCount: commentCount ?? this.commentCount,
      reportCount: reportCount ?? this.reportCount,
      isActive: isActive ?? this.isActive,
    );
  }
}
