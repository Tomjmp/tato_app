import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/features/inventory/domain/repositories/product_repository.dart';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';
import 'package:tato_app/features/movements/domain/repositories/movement_repository.dart';

/// Registers an inventory movement and keeps the product's stock in sync
/// in the same operation, so stock can never drift from movement history.
class RegisterMovementUseCase {
  final MovementRepository movementRepository;
  final ProductRepository productRepository;

  const RegisterMovementUseCase({
    required this.movementRepository,
    required this.productRepository,
  });

  Future<void> call(InventoryMovement movement) async {
    if (movement.quantity <= 0) {
      throw const ValidationFailure('La cantidad debe ser mayor a cero.');
    }

    final product = await productRepository.getProductById(movement.productId);
    if (product == null) {
      throw const ValidationFailure('El producto seleccionado no existe.');
    }

    final newStock = product.currentStock + movement.stockDelta;
    if (newStock < 0) {
      throw const ValidationFailure(
        'No hay suficiente stock disponible para esta salida.',
      );
    }

    await movementRepository.saveMovement(movement);
    await productRepository.saveProduct(
      product.copyWith(
        currentStock: newStock,
        updatedAt: DateTime.now(),
        synced: false,
      ),
    );
  }
}
