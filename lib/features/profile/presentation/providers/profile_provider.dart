import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

import 'profile_state.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ProfileRemoteDataSource()),
);

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository repository;

  ProfileNotifier(this.repository) : super(ProfileInitial());

  Future<void> getProfile() async {
    state = ProfileLoading();

    try {
      final profile = await repository.getProfile();

      state = ProfileLoaded(profile);
    } catch (e) {
      state = ProfileError(e.toString());
    }
  }

  Future<void> updateProfile({
    required String username,
    required String email,
  }) async {
    state = ProfileLoading();

    try {
      final profile = await repository.updateProfile(
        username: username,
        email: email,
      );

      state = ProfileLoaded(profile);
    } catch (e) {
      state = ProfileError(e.toString());
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      state = ProfileError(e.toString());
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(ref.read(profileRepositoryProvider)),
);
