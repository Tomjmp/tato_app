import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';
import 'package:tato_app/features/movements/domain/repositories/movement_repository.dart';

/// Registers an inventory movement. Keeping the product's stock in sync is
/// the repository's job, not this use case's: `MockMovementRepository`
/// does it in-memory, `SupabaseMovementRepository` delegates it to the
/// `register_movement` RPC, which validates and updates stock atomically
/// in the same transaction as the insert. This use case only enforces the
/// one rule that's cheap to check without touching a repository at all.
class RegisterMovementUseCase {
  final MovementRepository movementRepository;

  const RegisterMovementUseCase({required this.movementRepository});

  Future<void> call(InventoryMovement movement) async {
    if (movement.quantity <= 0) {
      throw const ValidationFailure('La cantidad debe ser mayor a cero.');
    }

    await movementRepository.saveMovement(movement);
  }
}
