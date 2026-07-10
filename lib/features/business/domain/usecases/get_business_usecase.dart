import 'package:tato_app/shared/models/business.dart';
import '../repositories/business_repository.dart';

/// Looks up the business belonging to a user — e.g. right after login, to
/// skip "Crear negocio" for a returning session. The mock repository has
/// no cross-session persistence, so this only finds a match within the
/// same app run.
class GetBusinessUseCase {
  final BusinessRepository repository;

  const GetBusinessUseCase(this.repository);

  Future<Business?> call({required String userId}) {
    return repository.getBusinessForUser(userId);
  }
}
