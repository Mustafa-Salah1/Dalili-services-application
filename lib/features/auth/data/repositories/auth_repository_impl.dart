import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_source.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthResponseModel> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      usernameOrEmail: usernameOrEmail,
      password: password,
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await remoteDataSource.register(
      username: username,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {}
}
