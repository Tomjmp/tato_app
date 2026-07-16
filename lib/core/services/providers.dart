import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/inventory/data/repositories/supabase_product_repository.dart';
import 'package:tato_app/features/inventory/domain/repositories/product_repository.dart';
import '../../features/movements/data/repositories/supabase_movement_repository.dart';
import 'package:tato_app/features/movements/domain/repositories/movement_repository.dart';
import 'package:tato_app/features/movements/domain/usecases/register_movement_usecase.dart';
import 'package:tato_app/features/insights/domain/usecases/calculate_insights_usecase.dart';
import 'package:tato_app/features/auth/data/datasource/supabase_auth_datasource.dart';
import 'package:tato_app/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:tato_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:tato_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:tato_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tato_app/features/business/data/datasource/supabase_business_datasource.dart';
import 'package:tato_app/features/business/data/repositories/supabase_business_repository.dart';
import 'package:tato_app/features/business/domain/repositories/business_repository.dart';
import 'package:tato_app/features/business/domain/usecases/create_business_usecase.dart';
import 'package:tato_app/features/business/domain/usecases/get_business_usecase.dart';
import 'package:tato_app/features/category/data/datasource/supabase_category_datasource.dart';
import 'package:tato_app/features/category/data/repositories/supabase_category_repository.dart';
import 'package:tato_app/features/category/domain/repositories/category_repository.dart';
import 'package:tato_app/features/category/domain/usecases/create_category_usecase.dart';
import 'package:tato_app/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:tato_app/features/category/domain/usecases/seed_default_categories_usecase.dart';
import 'package:tato_app/features/scanner/data/datasource/mock_classifier_datasource.dart';
import 'package:tato_app/features/scanner/data/repositories/mock_product_classifier_repository.dart';
import 'package:tato_app/features/scanner/domain/repositories/product_classifier_repository.dart';
import 'package:tato_app/features/scanner/domain/usecases/classify_product_usecase.dart';
import 'package:tato_app/shared/models/business.dart';
import 'package:tato_app/shared/models/user.dart';

// ─── Auth / Onboarding State ───────────────────────────────────────────────
// Seeded from any already-active Supabase session (e.g. app hot-restart)
// so a still-logged-in user isn't sent back to /login. Screens still update
// this directly on login/logout — there's no separate auth state stream.
final currentUserProvider = StateProvider<TatoUser?>((ref) {
  return SupabaseAuthDataSource.currentUserOrNull();
});

// ─── Business State ───────────────────────────────────────────────────────────
final currentBusinessProvider = StateProvider<Business?>((ref) => null);

// ─── UI-only preferences (no backend behind them yet) ──────────────────────
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

// ─── Repositories ─────────────────────────────────────────────────────────────
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return SupabaseProductRepository();
});

final movementRepositoryProvider = Provider<MovementRepository>((ref) {
  return SupabaseMovementRepository();
});

// ─── Use cases ──────────────────────────────────────────────────────────────
final registerMovementUseCaseProvider = Provider<RegisterMovementUseCase>((ref) {
  return RegisterMovementUseCase(
    movementRepository: ref.watch(movementRepositoryProvider),
  );
});

final calculateInsightsUseCaseProvider = Provider<CalculateInsightsUseCase>((ref) {
  return const CalculateInsightsUseCase();
});

// ─── Auth ───────────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(SupabaseAuthDataSource());
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

// ─── Business ───────────────────────────────────────────────────────────────
final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return SupabaseBusinessRepository(SupabaseBusinessDataSource());
});

final createBusinessUseCaseProvider = Provider<CreateBusinessUseCase>((ref) {
  return CreateBusinessUseCase(ref.watch(businessRepositoryProvider));
});

final getBusinessUseCaseProvider = Provider<GetBusinessUseCase>((ref) {
  return GetBusinessUseCase(ref.watch(businessRepositoryProvider));
});

// ─── Category ───────────────────────────────────────────────────────────────
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return SupabaseCategoryRepository(SupabaseCategoryDataSource());
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final createCategoryUseCaseProvider = Provider<CreateCategoryUseCase>((ref) {
  return CreateCategoryUseCase(ref.watch(categoryRepositoryProvider));
});

final seedDefaultCategoriesUseCaseProvider = Provider<SeedDefaultCategoriesUseCase>((ref) {
  return SeedDefaultCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

// ─── Scanner ────────────────────────────────────────────────────────────────
final productClassifierRepositoryProvider = Provider<ProductClassifierRepository>((ref) {
  // Swap MockProductClassifierRepository → MlKitProductClassifierRepository when ready
  return MockProductClassifierRepository(MockClassifierDataSource());
});

final classifyProductUseCaseProvider = Provider<ClassifyProductUseCase>((ref) {
  return ClassifyProductUseCase(
    classifierRepository: ref.watch(productClassifierRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
  );
});
