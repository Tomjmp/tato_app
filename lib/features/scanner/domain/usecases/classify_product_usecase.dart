import 'package:tato_app/features/category/domain/repositories/category_repository.dart';
import '../entities/classification_result.dart';
import '../repositories/product_classifier_repository.dart';

/// Suggests a category for the captured photo, chosen among the
/// classifying business's own categories — orchestrates `CategoryRepository`
/// (to know what's available) and `ProductClassifierRepository` (to pick one).
class ClassifyProductUseCase {
  final ProductClassifierRepository classifierRepository;
  final CategoryRepository categoryRepository;

  const ClassifyProductUseCase({
    required this.classifierRepository,
    required this.categoryRepository,
  });

  Future<ClassificationResult> call({required String businessId}) async {
    final categories = await categoryRepository.getCategories(businessId);
    return classifierRepository.classify(
      candidateCategories: categories.map((c) => c.name).toList(),
    );
  }
}
