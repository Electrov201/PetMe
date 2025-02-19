import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String id;
  final String organizationId;
  final String donorId;
  final double amount;
  final String upiId;
  final String transactionId;
  final String? purpose;
  final DateTime createdAt;
  final bool isVerified;
  final Map<String, dynamic>? metadata;

  DonationModel({
    required this.id,
    required this.organizationId,
    required this.donorId,
    required this.amount,
    required this.upiId,
    required this.transactionId,
    this.purpose,
    required this.createdAt,
    this.isVerified = false,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'donorId': donorId,
      'amount': amount,
      'upiId': upiId,
      'transactionId': transactionId,
      'purpose': purpose,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerified': isVerified,
      'metadata': metadata,
    };
  }

  factory DonationModel.fromMap(Map<String, dynamic> map) {
    return DonationModel(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      donorId: map['donorId'] as String,
      amount: (map['amount'] as num).toDouble(),
      upiId: map['upiId'] as String,
      transactionId: map['transactionId'] as String,
      purpose: map['purpose'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isVerified: map['isVerified'] as bool? ?? false,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}
