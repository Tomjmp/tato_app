import 'package:flutter/foundation.dart';

/// Outcome of classifying a captured product photo: a suggested category
/// and how confident the model is (0-100). The user always confirms or
/// overrides it before it's saved — TÁTO only ever suggests.
@immutable
class ClassificationResult {
  final String category;
  final int confidence;

  const ClassificationResult({required this.category, required this.confidence});
}
