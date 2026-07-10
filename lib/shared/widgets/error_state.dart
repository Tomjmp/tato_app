import 'package:flutter/material.dart';
import 'package:tato_app/core/constants/tato_constants.dart';

/// Standard friendly error placeholder for a failed load — never shows the
/// raw exception, matching CLAUDE.md's error-handling guideline. Today the
/// mock repositories never throw, so this only ever renders once real
/// repositories (Supabase) can fail.
class ErrorState extends StatelessWidget {
  final String message;

  const ErrorState({
    super.key,
    this.message = 'No se pudo cargar la información. Intenta de nuevo.',
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
                color: TatoColors.error.withOpacity(0.10),
                borderRadius: BorderRadius.circular(TatoSizes.radiusXl),
              ),
              child: const Icon(Icons.cloud_off_outlined,
                  size: 32, color: TatoColors.error),
            ),
            const SizedBox(height: TatoSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: TatoColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
