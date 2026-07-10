import 'dart:math';

import 'package:tato_app/core/constants/tato_constants.dart';
import '../../domain/entities/classification_result.dart';

/// Stands in for the on-device ML Kit model. Simulates inference latency
/// and returns a random category from the same list used everywhere else
/// in the app — swapping to a real `MlKitClassifierDataSource` later is a
/// one-file change.
class MockClassifierDataSource {
  Future<ClassificationResult> classify() async {
    await Future.delayed(const Duration(milliseconds: 1400));

    final candidates =
        TatoCategories.businessTypes.where((c) => c != 'Otro').toList();
    final random = Random();
    return ClassificationResult(
      category: candidates[random.nextInt(candidates.length)],
      confidence: 82 + random.nextInt(16), // 82–97%
    );
  }
}
