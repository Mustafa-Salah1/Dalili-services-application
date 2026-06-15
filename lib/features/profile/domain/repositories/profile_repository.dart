import '../../data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateProfile({
    required String username,
    required String email,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
