import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/inventory/data/repositories/mock_product_repository.dart';
import 'package:tato_app/features/inventory/domain/repositories/product_repository.dart';
import '../../features/movements/data/repositories/mock_movement_repository.dart';
import 'package:tato_app/features/movements/domain/repositories/movement_repository.dart';
import 'package:tato_app/features/movements/domain/usecases/register_movement_usecase.dart';
import 'package:tato_app/features/insights/domain/usecases/calculate_insights_usecase.dart';
import 'package:tato_app/shared/models/business.dart';
import 'package:tato_app/shared/models/user.dart';

// ─── Auth / Onboarding State ───────────────────────────────────────────────
// Starts as null so the app boots into Splash → Login → Crear negocio, the
// flow a first-time user would actually see. Screens update these providers
// directly since there is no backend yet — everything lives in memory.
final currentUserProvider = StateProvider<TatoUser?>((ref) => null);

// ─── Business State ───────────────────────────────────────────────────────────
final currentBusinessProvider = StateProvider<Business?>((ref) => null);

// ─── UI-only preferences (no backend behind them yet) ──────────────────────
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

// ─── Repositories ─────────────────────────────────────────────────────────────
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  // Swap MockProductRepository → SupabaseProductRepository when Supabase is ready
  return MockProductRepository();
});

final movementRepositoryProvider = Provider<MovementRepository>((ref) {
  // Swap MockMovementRepository → SupabaseMovementRepository when Supabase is ready
  return MockMovementRepository();
});

// ─── Use cases ──────────────────────────────────────────────────────────────
final registerMovementUseCaseProvider = Provider<RegisterMovementUseCase>((ref) {
  return RegisterMovementUseCase(
    movementRepository: ref.watch(movementRepositoryProvider),
    productRepository: ref.watch(productRepositoryProvider),
  );
});

final calculateInsightsUseCaseProvider = Provider<CalculateInsightsUseCase>((ref) {
  return const CalculateInsightsUseCase();
});
