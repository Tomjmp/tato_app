import 'package:tato_app/core/errors/failures.dart';
import 'package:tato_app/shared/models/user.dart';
import '../repositories/auth_repository.dart';

/// Validates credentials and starts a session. Used for both "Iniciar
/// sesión" and "Regístrate" — this mock stage has no real distinction
/// between the two (a real backend will add a separate RegisterUseCase).
class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<TatoUser> call({required String email, required String password}) {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw const ValidationFailure(
        'Ingresa tu correo y contraseña para continuar.',
      );
    }
    if (!trimmedEmail.contains('@')) {
      throw const ValidationFailure('Ingresa un correo electrónico válido.');
    }

    return repository.login(email: trimmedEmail, password: password);
  }
}
