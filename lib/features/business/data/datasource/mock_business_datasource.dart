import 'package:tato_app/shared/models/business.dart';

/// Stands in for a real remote call (e.g. Supabase). Keeps an in-memory
/// map keyed by userId so `getBusinessForUser` has something real to find
/// within the same app run — swapping to `SupabaseBusinessDataSource`
/// later is a one-file change.
class MockBusinessDataSource {
  final Map<String, Business> _businessesByUser = {};

  Future<Business> createBusiness({
    required String id,
    required String userId,
    required String name,
    required String category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    final business = Business(
      id: id,
      userId: userId,
      name: name,
      category: category,
      currency: 'DOP',
      createdAt: now,
      updatedAt: now,
      synced: false,
    );
    _businessesByUser[userId] = business;
    return business;
  }

  Future<Business?> getBusinessForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _businessesByUser[userId];
  }
}
