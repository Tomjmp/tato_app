import '../../domain/entities/classification_result.dart';
import '../../domain/repositories/product_classifier_repository.dart';
import '../datasource/mock_classifier_datasource.dart';

class MockProductClassifierRepository implements ProductClassifierRepository {
  final MockClassifierDataSource dataSource;

  const MockProductClassifierRepository(this.dataSource);

  @override
  Future<ClassificationResult> classify() => dataSource.classify();
}
