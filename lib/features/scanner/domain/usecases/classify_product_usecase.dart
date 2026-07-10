import '../entities/classification_result.dart';
import '../repositories/product_classifier_repository.dart';

class ClassifyProductUseCase {
  final ProductClassifierRepository repository;

  const ClassifyProductUseCase(this.repository);

  Future<ClassificationResult> call() => repository.classify();
}
