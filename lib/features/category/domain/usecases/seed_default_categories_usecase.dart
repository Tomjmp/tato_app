import 'package:uuid/uuid.dart';
import 'package:tato_app/core/constants/tato_constants.dart';
import '../repositories/category_repository.dart';

/// Creates the 9 default categories (Belleza, Alimentos, Bebidas, Cuidado
/// personal, Limpieza, Ropa, Accesorios, Colmado, Otro) for a newly created
/// business. Called from presentation right after `CreateBusinessUseCase`
/// succeeds — kept out of the `business` feature so it doesn't reach into
/// `category`'s repository across feature boundaries.
class SeedDefaultCategoriesUseCase {
  final CategoryRepository repository;

  const SeedDefaultCategoriesUseCase(this.repository);

  Future<void> call({required String businessId}) async {
    for (final name in TatoCategories.defaultProductCategories) {
      await repository.createCategory(
        id: const Uuid().v4(),
        businessId: businessId,
        name: name,
        isDefault: true,
      );
    }
  }
}
