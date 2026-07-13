import 'package:tato_app/shared/models/business.dart';
import '../../domain/repositories/business_repository.dart';
import '../datasource/supabase_business_datasource.dart';

class SupabaseBusinessRepository implements BusinessRepository {
  final SupabaseBusinessDataSource dataSource;

  const SupabaseBusinessRepository(this.dataSource);

  @override
  Future<Business> createBusiness({
    required String id,
    required String userId,
    required String name,
    required String category,
  }) {
    return dataSource.createBusiness(id: id, userId: userId, name: name, category: category);
  }

  @override
  Future<Business?> getBusinessForUser(String userId) {
    return dataSource.getBusinessForUser(userId);
  }
}
