import 'package:flutter/material.dart';
import 'package:tato_app/core/constants/tato_constants.dart';

/// −/number/+ control for whole-unit quantities. Never lets the value
/// drop below [min] — enforces "cantidad > 0" at the UI level instead of
/// only at submit time.
class QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final String label;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.label = 'UNIDADES',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: TatoSpacing.md),
      decoration: BoxDecoration(
        color: TatoColors.surface,
        borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
        border: Border.all(color: TatoColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          Column(
            children: [
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: TatoColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          _StepButton(icon: Icons.add, onTap: () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? TatoColors.surfaceVariant : TatoColors.surfaceVariant.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: enabled ? TatoColors.primary : TatoColors.outline),
      ),
    );
  }
}
