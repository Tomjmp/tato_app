import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/core/errors/supabase_error_mapper.dart';
import 'package:tato_app/shared/models/business.dart';

/// Talks to the `businesses` table. Creation goes through the
/// `create_business_with_default_categories` RPC (0006_functions.sql) so
/// the business row and its 9 default categories are inserted atomically —
/// never a separate `insert business` + `insert categories` from Flutter.
class SupabaseBusinessDataSource {
  final SupabaseClient _client;

  SupabaseBusinessDataSource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<Business> createBusiness({
    required String id,
    required String userId,
    required String name,
    required String category,
  }) async {
    try {
      final row = await _client.rpc('create_business_with_default_categories', params: {
        'p_id': id,
        'p_name': name,
        'p_category': category,
      });
      return _mapBusiness(row as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }

  Future<Business?> getBusinessForUser(String userId) async {
    try {
      final row = await _client
          .from('businesses')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (row == null) return null;
      return _mapBusiness(row);
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }

  Business _mapBusiness(Map<String, dynamic> row) {
    return Business(
      id: row['id'] as String,
      userId: row['owner_id'] as String,
      name: row['name'] as String,
      category: row['category'] as String,
      currency: row['currency'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      synced: true,
    );
  }
}
