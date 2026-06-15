import '../../data/models/admin_application_model.dart';

abstract class AdminRepository {
  Future<List<AdminApplicationModel>> getApplications();

  Future<void> approveApplication(int id);

  Future<void> rejectApplication(int id);
}
