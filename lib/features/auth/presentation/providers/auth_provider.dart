import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_finder/features/auth/presentation/providers/auth_state.dart';

import '../../data/datasources/auth_remote_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:service_finder/core/storage/secure_storage_service.dart';
import '../../data/models/auth_response_model.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(AuthRemoteDataSource()),
);

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(AuthInitial());

  Future<void> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    state = AuthLoading();

    try {
      final AuthResponseModel response = await repository.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );

      await SecureStorageService.saveAccessToken(response.accessToken);

      await SecureStorageService.saveRefreshToken(response.refreshToken);

      state = AuthAuthenticated();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = AuthLoading();

    try {
      await repository.register(
        username: username,
        email: email,
        password: password,
      );

      state = AuthAuthenticated();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
