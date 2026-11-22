import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/notifications/domain/entities/notification_entity.dart';
import 'package:skillswap/features/notifications/domain/usecases/mark_notifications_read_usecase.dart';
import 'package:skillswap/features/notifications/domain/usecases/watch_notifications_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final WatchNotificationsUseCase watchNotifications;
  final MarkNotificationsReadUseCase markRead;

  StreamSubscription<List<NotificationEntity>>? _sub;

  NotificationBloc({
    required this.watchNotifications,
    required this.markRead,
  }) : super(const NotificationLoading()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsReceived>((e, emit) => emit(NotificationLoaded(e.items)));
    on<NotificationsStreamFailed>((e, emit) {
      emit(const NotificationFailure('Impossible de charger les notifications'));
    });
    on<NotificationsMarkedRead>((e, emit) async {
      // Le flux Firestore réémet la liste mise à jour tout seul.
      await markRead(e.ids);
    });
  }

  Future<void> _onStarted(
      NotificationsStarted event, Emitter<NotificationState> emit) async {
    emit(const NotificationLoading());
    await _sub?.cancel();
    _sub = watchNotifications(event.uid).listen(
      (items) => add(NotificationsReceived(items)),
      onError: (_) => add(const NotificationsStreamFailed()),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}