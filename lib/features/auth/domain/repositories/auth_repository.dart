import '../../data/models/auth_response_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login({
    required String usernameOrEmail,
    required String password,
  });

  Future<void> register({
    required String username,
    required String email,
    required String password,
  });

  Future<void> logout();
}
