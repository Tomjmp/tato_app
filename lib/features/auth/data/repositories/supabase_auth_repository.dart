import 'package:tato_app/shared/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/supabase_auth_datasource.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseAuthDataSource dataSource;

  const SupabaseAuthRepository(this.dataSource);

  @override
  Future<TatoUser> login({required String email, required String password}) {
    return dataSource.login(email: email, password: password);
  }

  @override
  Future<void> logout() {
    return dataSource.logout();
  }
}
