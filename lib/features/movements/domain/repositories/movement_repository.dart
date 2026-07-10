import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';

abstract interface class MovementRepository {
  Future<List<InventoryMovement>> getMovements({String? productId});
  Future<void> saveMovement(InventoryMovement movement);
  Stream<List<InventoryMovement>> watchMovements();
}
