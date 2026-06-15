import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/admin_remote_data_source.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';

import 'admin_state.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepositoryImpl(AdminRemoteDataSource()),
);

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository repository;

  AdminNotifier(this.repository) : super(AdminInitial());

  Future<void> getApplications() async {
    state = AdminLoading();

    try {
      final applications = await repository.getApplications();

      state = AdminLoaded(applications);
    } catch (e) {
      state = AdminError(e.toString());
    }
  }

  Future<void> approveApplication(int id) async {
    try {
      await repository.approveApplication(id);

      await getApplications();
    } catch (e) {
      state = AdminError(e.toString());
    }
  }

  Future<void> rejectApplication(int id) async {
    try {
      await repository.rejectApplication(id);

      await getApplications();
    } catch (e) {
      state = AdminError(e.toString());
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>(
  (ref) => AdminNotifier(ref.read(adminRepositoryProvider)),
);
