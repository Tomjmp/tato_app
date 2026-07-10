import 'package:flutter/material.dart';
import 'package:tato_app/core/constants/tato_constants.dart';

enum CustomButtonVariant { primary, secondary, outline, danger }

/// Full-width action button with consistent height, radius and loading
/// state across the app, so every primary CTA looks the same.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  Color get _background {
    switch (variant) {
      case CustomButtonVariant.primary:
      case CustomButtonVariant.secondary:
        // Mockups use a single, monochromatic blue for every solid CTA.
        return TatoColors.primary;
      case CustomButtonVariant.outline:
        return Colors.transparent;
      case CustomButtonVariant.danger:
        return TatoColors.error;
    }
  }

  Color get _foreground {
    return variant == CustomButtonVariant.outline
        ? TatoColors.primary
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;
    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: _foreground),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _foreground,
                ),
              ),
            ],
          );

    final button = variant == CustomButtonVariant.outline
        ? OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: TatoColors.border, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
              ),
            ),
            child: child,
          )
        : FilledButton(
            onPressed: isDisabled ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: _background,
              disabledBackgroundColor: _background.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TatoSizes.radiusMd),
              ),
            ),
            child: child,
          );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: TatoSizes.minTouchTarget,
      child: button,
    );
  }
}
