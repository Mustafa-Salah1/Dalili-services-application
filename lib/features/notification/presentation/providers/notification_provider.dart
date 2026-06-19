import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(NotificationRemoteDataSource()),
);

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository repository;

  NotificationNotifier(this.repository) : super(NotificationInitial());

  Future<void> getNotifications() async {
    state = NotificationLoading();

    try {
      final List<NotificationModel> notifications = await repository
          .getNotifications();

      state = NotificationLoaded(notifications);
    } catch (e) {
      state = NotificationError(e.toString());
    }
  }

  Future<void> markAsRead(int id) async {
    await repository.markAsRead(id);

    await getNotifications();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
      (ref) => NotificationNotifier(ref.read(notificationRepositoryProvider)),
    );
