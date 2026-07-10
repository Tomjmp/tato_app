import 'package:flutter/foundation.dart';

@immutable
class Business {
  final String localId;
  final String? cloudId;
  final String userId;
  final String name;
  final String category;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  const Business({
    required this.localId,
    this.cloudId,
    required this.userId,
    required this.name,
    required this.category,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });

  Business copyWith({
    String? localId,
    String? cloudId,
    String? userId,
    String? name,
    String? category,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return Business(
      localId: localId ?? this.localId,
      cloudId: cloudId ?? this.cloudId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'cloudId': cloudId,
      'userId': userId,
      'name': name,
      'category': category,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'synced': synced,
    };
  }

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      localId: json['localId'] as String,
      cloudId: json['cloudId'] as String?,
      userId: json['userId'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      synced: json['synced'] as bool,
    );
  }
}
