import 'package:flutter/foundation.dart';

/// A product category, scoped to a single business and editable by its
/// owner. `isDefault` marks the ones auto-seeded when the business was
/// created (Belleza, Alimentos, etc.) versus ones the user added later.
@immutable
class Category {
  final String id;
  final String businessId;
  final String name;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.businessId,
    required this.name,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    String? id,
    String? businessId,
    String? name,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      name: json['name'] as String,
      isDefault: json['isDefault'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
