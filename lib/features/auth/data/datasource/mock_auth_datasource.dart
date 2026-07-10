import 'package:tato_app/shared/models/user.dart';

/// Stands in for a real remote call (e.g. Supabase Auth). Kept separate
/// from the repository so swapping to `SupabaseAuthDataSource` later is a
/// one-file change — `MockAuthRepository` and everything above it stays
/// the same.
class MockAuthDataSource {
  Future<TatoUser> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final name = email.split('@').first;
    return TatoUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name.isEmpty ? 'Usuario' : name[0].toUpperCase() + name.substring(1),
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
