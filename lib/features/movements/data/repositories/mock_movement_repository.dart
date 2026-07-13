import 'dart:async';
import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/features/inventory/domain/repositories/product_repository.dart';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';
import 'package:tato_app/features/movements/domain/repositories/movement_repository.dart';
import 'package:tato_app/core/services/mock_data.dart';

/// The mock has no database-level RPC, so it replicates what
/// `register_movement` (0006_functions.sql) does for real: read the
/// product, validate/compute the new stock, then save both the movement
/// and the updated product. `RegisterMovementUseCase` stays a thin
/// passthrough that works the same way against this or
/// `SupabaseMovementRepository`.
class MockMovementRepository implements MovementRepository {
  final ProductRepository productRepository;
  final List<InventoryMovement> _movements = List.from(MockData.movements);
  final _controller = StreamController<List<InventoryMovement>>.broadcast();

  MockMovementRepository(this.productRepository);

  @override
  Future<List<InventoryMovement>> getMovements({String? productId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (productId != null) {
      return _movements.where((m) => m.productId == productId).toList();
    }
    return List.unmodifiable(_movements);
  }

  @override
  Future<void> saveMovement(InventoryMovement movement) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final product = await productRepository.getProductById(movement.productId);
    if (product == null) {
      throw const ValidationFailure('El producto seleccionado no existe.');
    }

    final newStock = product.currentStock + movement.stockDelta;
    if (newStock < 0) {
      throw const ValidationFailure('No hay suficiente stock disponible para esta salida.');
    }

    _movements.insert(0, movement);
    _controller.add(List.unmodifiable(_movements));

    await productRepository.saveProduct(
      product.copyWith(currentStock: newStock, updatedAt: DateTime.now(), synced: false),
    );
  }

  @override
  Stream<List<InventoryMovement>> watchMovements() {
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
