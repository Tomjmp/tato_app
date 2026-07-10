import 'package:tato_app/shared/models/business.dart';

abstract interface class BusinessRepository {
  Future<Business> createBusiness({
    required String userId,
    required String name,
    required String category,
  });

  Future<Business?> getBusinessForUser(String userId);
}
