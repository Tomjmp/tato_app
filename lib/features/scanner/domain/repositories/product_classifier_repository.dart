import '../entities/classification_result.dart';

abstract interface class ProductClassifierRepository {
  /// Classifies the most recently captured photo, choosing among
  /// [candidateCategories] (the classifying business's own categories —
  /// suggesting a name the business doesn't have would be inconsistent).
  /// Takes no image yet because there is no real camera capture to pass
  /// along — once ML Kit is wired up this will also take the captured image.
  Future<ClassificationResult> classify({required List<String> candidateCategories});
}
