import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';
import '../models/admin_application_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AdminApplicationModel>> getApplications() async {
    final response = await remoteDataSource.getApplications();

    return (response.data as List)
        .map((e) => AdminApplicationModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> approveApplication(int id) async {
    await remoteDataSource.approveApplication(id);
  }

  @override
  Future<void> rejectApplication(int id) async {
    await remoteDataSource.rejectApplication(id);
  }
}
