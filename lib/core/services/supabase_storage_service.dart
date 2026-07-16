import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/core/errors/supabase_error_mapper.dart';

/// Uploads to the `product-images` bucket (0007_storage.sql), which
/// requires paths of the form `{business_id}/{product_id}/{filename}` — the
/// storage RLS policies check that first path segment against the caller's
/// own businesses. Not wired to any screen yet: no product form in the app
/// currently captures a real photo (`ProductAvatar` only renders an
/// icon/color placeholder), so this exists ready for when that UI ships.
class SupabaseStorageService {
  final SupabaseClient _client;

  SupabaseStorageService([SupabaseClient? client]) : _client = client ?? Supabase.instance.client;

  static const _bucket = 'product-images';

  Future<String> uploadProductImage({
    required String businessId,
    required String productId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final path = '$businessId/$productId/$fileName';
    try {
      await _client.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      return _client.storage.from(_bucket).getPublicUrl(path);
    } on StorageException catch (e) {
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }
}
