import 'package:flutter/foundation.dart';

@immutable
class Business {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  const Business({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });

  Business copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return Business(
      id: id ?? this.id,
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
      'id': id,
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
      id: json['id'] as String,
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
