import 'package:flutter/material.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';

const _monthNames = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

String formatMovementDate(DateTime date) {
  final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final period = date.hour < 12 ? 'a.m.' : 'p.m.';
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${_monthNames[date.month - 1]}, $hour12:$minute $period';
}

/// Single row for a movement: direction icon, type/reason, date and the
/// signed quantity. Used in Product Detail's history and the Dashboard's
/// "Movimientos recientes" feed.
class MovementTile extends StatelessWidget {
  final InventoryMovement movement;
  final bool showProductName;

  const MovementTile({
    super.key,
    required this.movement,
    this.showProductName = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = movement.stockDelta > 0;
    final color = isPositive ? TatoColors.success : TatoColors.error;
    final icon = movement.isAdjustment
        ? Icons.tune_outlined
        : (isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TatoSpacing.md,
        vertical: TatoSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: TatoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showProductName
                      ? movement.productName
                      : '${movement.type.label} · ${movement.reason}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  showProductName
                      ? '${movement.type.label} · ${formatMovementDate(movement.date)}'
                      : formatMovementDate(movement.date),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: TatoColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}${movement.quantity.toInt()}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
