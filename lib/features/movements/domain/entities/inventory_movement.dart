import 'package:flutter/foundation.dart';

enum MovementType { entry, exit, adjustment }

extension MovementTypeLabel on MovementType {
  String get label {
    switch (this) {
      case MovementType.entry:
        return 'Entrada';
      case MovementType.exit:
        return 'Salida';
      case MovementType.adjustment:
        return 'Ajuste';
    }
  }
}

@immutable
class InventoryMovement {
  final String localId;
  final String? cloudId;
  final String productId;
  final String productName;
  final MovementType type;
  final double quantity;
  final String reason; // "Venta", "Compra", "Merma", "Conteo físico", etc.
  final String? note;

  /// Only meaningful when [type] is [MovementType.adjustment]: whether the
  /// correction adds stock (true) or removes stock (false).
  final bool? increasesStock;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  const InventoryMovement({
    required this.localId,
    this.cloudId,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.reason,
    this.note,
    this.increasesStock,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });

  bool get isEntry => type == MovementType.entry;
  bool get isExit => type == MovementType.exit;
  bool get isAdjustment => type == MovementType.adjustment;

  /// Signed effect of this movement on product stock.
  double get stockDelta {
    switch (type) {
      case MovementType.entry:
        return quantity;
      case MovementType.exit:
        return -quantity;
      case MovementType.adjustment:
        return (increasesStock ?? true) ? quantity : -quantity;
    }
  }

  InventoryMovement copyWith({
    String? localId,
    String? cloudId,
    String? productId,
    String? productName,
    MovementType? type,
    double? quantity,
    String? reason,
    String? note,
    bool? increasesStock,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return InventoryMovement(
      localId: localId ?? this.localId,
      cloudId: cloudId ?? this.cloudId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      increasesStock: increasesStock ?? this.increasesStock,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'cloudId': cloudId,
        'productId': productId,
        'productName': productName,
        'type': type.name,
        'quantity': quantity,
        'reason': reason,
        'note': note,
        'increasesStock': increasesStock,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'synced': synced,
      };

  factory InventoryMovement.fromJson(Map<String, dynamic> json) {
    return InventoryMovement(
      localId: json['localId'] as String,
      cloudId: json['cloudId'] as String?,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      type: MovementType.values.byName(json['type'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      reason: json['reason'] as String,
      note: json['note'] as String?,
      increasesStock: json['increasesStock'] as bool?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      synced: json['synced'] as bool,
    );
  }
}
