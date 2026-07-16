import 'package:tato_app/shared/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/mock_auth_datasource.dart';

class MockAuthRepository implements AuthRepository {
  final MockAuthDataSource dataSource;

  const MockAuthRepository(this.dataSource);

  @override
  Future<TatoUser> login({required String email, required String password}) {
    return dataSource.login(email: email, password: password);
  }

  @override
  Future<void> logout() {
    return dataSource.logout();
  }
}
