import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/core/errors/supabase_error_mapper.dart';
import 'package:tato_app/features/movements/domain/entities/inventory_movement.dart';
import 'package:tato_app/features/movements/domain/repositories/movement_repository.dart';

/// Talks to `inventory_movements` (0005_inventory_movements.sql). Writes
/// never touch this table (or `products.current_stock`) directly —
/// `saveMovement` only calls the `register_movement` RPC
/// (0006_functions.sql), which validates stock, inserts the movement and
/// updates the product atomically in a single locked transaction. This
/// repository does not read the product, compute the new stock, or write
/// it back — that flow is fully replaced by the RPC.
class SupabaseMovementRepository implements MovementRepository {
  final SupabaseClient _client;

  SupabaseMovementRepository([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  static const _selectWithProduct = '*, products(name)';

  @override
  Future<List<InventoryMovement>> getMovements({String? productId}) async {
    try {
      var query = _client.from('inventory_movements').select(_selectWithProduct);
      if (productId != null) {
        query = query.eq('product_id', productId);
      }
      final rows = await query.order('date', ascending: false);
      return (rows as List).map((r) => _mapMovement(r as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }

  @override
  Future<void> saveMovement(InventoryMovement movement) async {
    try {
      await _client.rpc('register_movement', params: {
        'p_id': movement.id,
        'p_product_id': movement.productId,
        'p_type': movement.type.name,
        'p_quantity': movement.quantity,
        'p_reason': movement.reason,
        'p_note': movement.note,
        'p_increases_stock': movement.increasesStock,
        'p_date': movement.date.toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }

  @override
  Stream<List<InventoryMovement>> watchMovements() {
    // Realtime .stream() only mirrors the raw table (no relational
    // embedding), so productName falls back to an empty string on this
    // path — acceptable since nothing in the app currently consumes
    // watchMovements().
    return _client
        .from('inventory_movements')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false)
        .map((rows) => rows.map((r) => _mapMovementRow(r, productName: '')).toList());
  }

  InventoryMovement _mapMovement(Map<String, dynamic> row) {
    final productName = (row['products'] as Map<String, dynamic>?)?['name'] as String? ?? '';
    return _mapMovementRow(row, productName: productName);
  }

  InventoryMovement _mapMovementRow(Map<String, dynamic> row, {required String productName}) {
    return InventoryMovement(
      id: row['id'] as String,
      productId: row['product_id'] as String,
      productName: productName,
      type: MovementType.values.byName(row['type'] as String),
      quantity: (row['quantity'] as num).toDouble(),
      reason: row['reason'] as String,
      note: row['note'] as String?,
      increasesStock: row['increases_stock'] as bool?,
      date: DateTime.parse(row['date'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['created_at'] as String),
      synced: true,
    );
  }
}
