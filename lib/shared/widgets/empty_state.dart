import 'package:flutter/material.dart';
import 'package:tato_app/core/constants/tato_constants.dart';

/// Standard "nothing here yet" placeholder, with an optional call to action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TatoSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TatoColors.surfaceVariant,
                borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
              ),
              child: Icon(icon, size: 32, color: TatoColors.onSurfaceVariant),
            ),
            const SizedBox(height: TatoSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TatoColors.onSurfaceVariant,
                    ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: TatoSpacing.lg),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: TatoColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
                  ),
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
