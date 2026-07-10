import 'dart:async';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';
import 'package:tato_app/features/movements/domain/repositories/movement_repository.dart';
import 'package:tato_app/core/services/mock_data.dart';

class MockMovementRepository implements MovementRepository {
  final List<InventoryMovement> _movements = List.from(MockData.movements);
  final _controller = StreamController<List<InventoryMovement>>.broadcast();

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
    _movements.insert(0, movement);
    _controller.add(List.unmodifiable(_movements));
  }

  @override
  Stream<List<InventoryMovement>> watchMovements() {
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
