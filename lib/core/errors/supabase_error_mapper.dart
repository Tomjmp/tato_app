import 'package:supabase_flutter/supabase_flutter.dart';

import 'failures.dart';

/// Translates Supabase SDK exceptions into the app's existing [Failure]
/// hierarchy, so every `SupabaseXRepository` surfaces the same friendly,
/// Spanish error messages the UI already knows how to display — never a
/// raw [PostgrestException]/[AuthException].
Failure mapSupabaseError(Object error) {
  if (error is AuthException) {
    return ValidationFailure(_friendlyAuthMessage(error));
  }
  if (error is PostgrestException) {
    return _mapPostgrestException(error);
  }
  if (error is StorageException) {
    return ServerFailure(error.message);
  }
  return const NetworkFailure();
}

Failure _mapPostgrestException(PostgrestException e) {
  // unique_violation — e.g. a category seeded twice for the same negocio.
  if (e.code == '23505') {
    return const ValidationFailure('Ya existe un registro con esos datos.');
  }
  // insufficient_privilege / RLS denies the row entirely.
  if (e.code == '42501' || e.code == 'PGRST301') {
    return const ValidationFailure('No tienes permiso para realizar esta acción.');
  }
  // Our own RPCs (register_movement, create_business_with_default_categories)
  // raise exception with a message already written in plain Spanish for the
  // user — pass it straight through instead of wrapping it further.
  if (e.message.isNotEmpty) {
    return ValidationFailure(e.message);
  }
  return const ServerFailure();
}

String _friendlyAuthMessage(AuthException e) {
  final msg = e.message.toLowerCase();
  if (msg.contains('invalid login credentials')) {
    return 'Correo o contraseña incorrectos.';
  }
  if (msg.contains('already registered')) {
    return 'Ya existe una cuenta con este correo.';
  }
  if (msg.contains('email not confirmed')) {
    return 'Debes confirmar tu correo antes de iniciar sesión.';
  }
  if (msg.contains('password') && msg.contains('least')) {
    return 'La contraseña es demasiado corta.';
  }
  return e.message;
}
