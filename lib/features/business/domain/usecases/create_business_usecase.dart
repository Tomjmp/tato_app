import 'package:uuid/uuid.dart';
import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/shared/models/business.dart';
import '../repositories/business_repository.dart';

class CreateBusinessUseCase {
  final BusinessRepository repository;

  const CreateBusinessUseCase(this.repository);

  Future<Business> call({
    required String userId,
    required String name,
    required String? category,
  }) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw const ValidationFailure('Ingresa el nombre de tu negocio.');
    }
    if (category == null || category.isEmpty) {
      throw const ValidationFailure('Selecciona el tipo de negocio.');
    }

    return repository.createBusiness(
      id: const Uuid().v4(),
      userId: userId,
      name: trimmedName,
      category: category,
    );
  }
}
