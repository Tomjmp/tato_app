import 'package:flutter/foundation.dart';

enum ProductStatus { inStock, lowStock, outOfStock }

@immutable
class Product {
  final String localId;
  final String? cloudId;
  final String businessId;
  final String name;
  final String? description;
  final String? sku;
  final String? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final double price;
  final double cost;
  final double currentStock;
  final double minStockAlert;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  const Product({
    required this.localId,
    this.cloudId,
    required this.businessId,
    required this.name,
    this.description,
    this.sku,
    this.categoryId,
    this.categoryName,
    this.imageUrl,
    required this.price,
    required this.cost,
    required this.currentStock,
    required this.minStockAlert,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });

  ProductStatus get status {
    if (currentStock <= 0) return ProductStatus.outOfStock;
    if (currentStock <= minStockAlert) return ProductStatus.lowStock;
    return ProductStatus.inStock;
  }

  double get totalValue => currentStock * cost;

  bool get needsAttention =>
      status == ProductStatus.outOfStock || status == ProductStatus.lowStock;

  Product copyWith({
    String? localId,
    String? cloudId,
    String? businessId,
    String? name,
    String? description,
    String? sku,
    String? categoryId,
    String? categoryName,
    String? imageUrl,
    double? price,
    double? cost,
    double? currentStock,
    double? minStockAlert,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return Product(
      localId: localId ?? this.localId,
      cloudId: cloudId ?? this.cloudId,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      currentStock: currentStock ?? this.currentStock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'cloudId': cloudId,
      'businessId': businessId,
      'name': name,
      'description': description,
      'sku': sku,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
      'price': price,
      'cost': cost,
      'currentStock': currentStock,
      'minStockAlert': minStockAlert,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'synced': synced,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      localId: json['localId'] as String,
      cloudId: json['cloudId'] as String?,
      businessId: json['businessId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      currentStock: (json['currentStock'] as num).toDouble(),
      minStockAlert: (json['minStockAlert'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      synced: json['synced'] as bool,
    );
  }
}
