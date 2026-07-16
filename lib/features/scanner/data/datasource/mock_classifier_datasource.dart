import 'dart:math';

import '../../domain/entities/classification_result.dart';

/// Stands in for the on-device ML Kit model. Simulates inference latency
/// and returns a random pick among the business's own categories —
/// swapping to a real `MlKitClassifierDataSource` later is a one-file
/// change.
class MockClassifierDataSource {
  Future<ClassificationResult> classify({
    required List<String> candidateCategories,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1400));

    final candidates = candidateCategories.where((c) => c != 'Otro').toList();
    if (candidates.isEmpty) candidates.addAll(candidateCategories);
    if (candidates.isEmpty) {
      return const ClassificationResult(category: 'Otro', confidence: 50);
    }

    final random = Random();
    return ClassificationResult(
      category: candidates[random.nextInt(candidates.length)],
      confidence: 82 + random.nextInt(16), // 82–97%
    );
  }
}
