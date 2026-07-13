import 'package:uuid/uuid.dart';
import 'package:tato_app/core/errors/failures.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Creates a user-defined category for a business. Prepared for the future
/// "administrar categorías" screen — not wired to any UI yet, only the
/// default-seeded categories are used in the MVP.
class CreateCategoryUseCase {
  final CategoryRepository repository;

  const CreateCategoryUseCase(this.repository);

  Future<Category> call({required String businessId, required String name}) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationFailure('Ingresa el nombre de la categoría.');
    }

    return repository.createCategory(
      id: const Uuid().v4(),
      businessId: businessId,
      name: trimmedName,
    );
  }
}
