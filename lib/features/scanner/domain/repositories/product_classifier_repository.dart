import '../entities/classification_result.dart';

abstract interface class ProductClassifierRepository {
  /// Classifies the most recently captured photo. Takes no arguments yet
  /// because there is no real camera capture to pass along — once ML Kit
  /// is wired up this will take the captured image.
  Future<ClassificationResult> classify();
}
