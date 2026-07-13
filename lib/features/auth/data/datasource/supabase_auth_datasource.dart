import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/core/errors/supabase_error_mapper.dart';
import 'package:tato_app/shared/models/user.dart';

/// Talks to Supabase Auth. The UI has a single form for both "Iniciar
/// sesión" and "Regístrate" (see `LoginScreen`), both wired to the same
/// `login()` call — so this tries signUp first (succeeds for a first-time
/// email) and falls back to signInWithPassword when the email is already
/// registered, giving an accurate "contraseña incorrecta" for a returning
/// user who mistypes their password instead of a misleading signUp error.
class SupabaseAuthDataSource {
  final SupabaseClient _client;

  SupabaseAuthDataSource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<TatoUser> login({required String email, required String password}) async {
    try {
      final signUpResponse = await _client.auth.signUp(email: email, password: password);
      final user = signUpResponse.user;
      if (user != null) return _mapUser(user);
      throw const ServerFailure('No se pudo crear la cuenta.');
    } on AuthException catch (e) {
      if (!_isAlreadyRegistered(e)) throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }

    try {
      final signInResponse =
          await _client.auth.signInWithPassword(email: email, password: password);
      final user = signInResponse.user;
      if (user == null) throw const ServerFailure('No se pudo iniciar sesión.');
      return _mapUser(user);
    } on AuthException catch (e) {
      throw mapSupabaseError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw const NetworkFailure();
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw mapSupabaseError(e);
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  TatoUser? currentUser() {
    final user = _client.auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  /// Same as [currentUser], but safe to call before `Supabase.initialize()`
  /// has run (e.g. widget tests that build `TatoApp` directly) — returns
  /// null instead of throwing.
  static TatoUser? currentUserOrNull() {
    try {
      return SupabaseAuthDataSource().currentUser();
    } catch (_) {
      return null;
    }
  }

  bool _isAlreadyRegistered(AuthException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('already registered') || msg.contains('already exists');
  }

  TatoUser _mapUser(User user) {
    final metaName = user.userMetadata?['name'] as String?;
    final emailLocalPart = user.email?.split('@').first;
    final fallbackName = (emailLocalPart == null || emailLocalPart.isEmpty)
        ? null
        : emailLocalPart[0].toUpperCase() + emailLocalPart.substring(1);
    return TatoUser(
      id: user.id,
      email: user.email ?? '',
      name: metaName ?? fallbackName,
    );
  }
}
