import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileModel> getProfile() async {
    final response = await remoteDataSource.getProfile();

    return ProfileModel.fromJson(response.data);
  }

  @override
  Future<ProfileModel> updateProfile({
    required String username,
    required String email,
  }) async {
    final response = await remoteDataSource.updateProfile(
      username: username,
      email: email,
    );

    return ProfileModel.fromJson(response.data);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
