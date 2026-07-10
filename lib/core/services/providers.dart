import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/inventory/data/repositories/mock_product_repository.dart';
import 'package:tato_app/features/inventory/domain/repositories/product_repository.dart';
import '../../features/movements/data/repositories/mock_movement_repository.dart';
import 'package:tato_app/features/movements/domain/repositories/movement_repository.dart';
import 'package:tato_app/features/movements/domain/usecases/register_movement_usecase.dart';
import 'package:tato_app/features/insights/domain/usecases/calculate_insights_usecase.dart';
import 'package:tato_app/features/auth/data/datasource/mock_auth_datasource.dart';
import 'package:tato_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:tato_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:tato_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:tato_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tato_app/features/business/data/datasource/mock_business_datasource.dart';
import 'package:tato_app/features/business/data/repositories/mock_business_repository.dart';
import 'package:tato_app/features/business/domain/repositories/business_repository.dart';
import 'package:tato_app/features/business/domain/usecases/create_business_usecase.dart';
import 'package:tato_app/features/business/domain/usecases/get_business_usecase.dart';
import 'package:tato_app/features/scanner/data/datasource/mock_classifier_datasource.dart';
import 'package:tato_app/features/scanner/data/repositories/mock_product_classifier_repository.dart';
import 'package:tato_app/features/scanner/domain/repositories/product_classifier_repository.dart';
import 'package:tato_app/features/scanner/domain/usecases/classify_product_usecase.dart';
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

// ─── Auth ───────────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Swap MockAuthRepository → SupabaseAuthRepository when Supabase is ready
  return MockAuthRepository(MockAuthDataSource());
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

// ─── Business ───────────────────────────────────────────────────────────────
final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  // Swap MockBusinessRepository → SupabaseBusinessRepository when Supabase is ready
  return MockBusinessRepository(MockBusinessDataSource());
});

final createBusinessUseCaseProvider = Provider<CreateBusinessUseCase>((ref) {
  return CreateBusinessUseCase(ref.watch(businessRepositoryProvider));
});

final getBusinessUseCaseProvider = Provider<GetBusinessUseCase>((ref) {
  return GetBusinessUseCase(ref.watch(businessRepositoryProvider));
});

// ─── Scanner ────────────────────────────────────────────────────────────────
final productClassifierRepositoryProvider = Provider<ProductClassifierRepository>((ref) {
  // Swap MockProductClassifierRepository → MlKitProductClassifierRepository when ready
  return MockProductClassifierRepository(MockClassifierDataSource());
});

final classifyProductUseCaseProvider = Provider<ClassifyProductUseCase>((ref) {
  return ClassifyProductUseCase(ref.watch(productClassifierRepositoryProvider));
});
