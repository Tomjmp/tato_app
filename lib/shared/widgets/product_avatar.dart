import 'package:flutter/material.dart';
import 'package:tato_app/core/constants/tato_constants.dart';

/// Product "photo" slot. Renders a real image when [imageUrl] is set;
/// otherwise falls back to a category-tinted icon placeholder so every
/// product still reads as visually distinct in lists and detail views.
class ProductAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? categoryName;
  final double size;
  final double radius;

  /// Cuando se pasa, el avatar "vuela" entre la lista y el detalle (Hero).
  final Object? heroTag;

  const ProductAvatar({
    super.key,
    this.imageUrl,
    this.categoryName,
    this.size = 48,
    this.radius = TatoSizes.radiusMd,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = _buildAvatar(context);
    if (heroTag == null) return avatar;
    return Hero(
      tag: heroTag!,
      flightShuttleBuilder: (_, __, ___, ____, toContext) =>
          (toContext.widget as Hero).child,
      child: avatar,
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final color = TatoCategories.colorFor(categoryName);
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: imageUrl == null
          ? Icon(
              TatoCategories.iconFor(categoryName),
              color: color,
              size: size * 0.46,
            )
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                TatoCategories.iconFor(categoryName),
                color: color,
                size: size * 0.46,
              ),
            ),
    );
  }
}
