import 'package:tato_app/shared/models/user.dart';

abstract interface class AuthRepository {
  Future<TatoUser> login({required String email, required String password});
  Future<void> logout();
}
