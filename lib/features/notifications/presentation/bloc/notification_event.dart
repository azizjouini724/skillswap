part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsStarted extends NotificationEvent {
  final String uid;
  const NotificationsStarted(this.uid);

  @override
  List<Object?> get props => [uid];
}

class NotificationsReceived extends NotificationEvent {
  final List<NotificationEntity> items;
  const NotificationsReceived(this.items);

  @override
  List<Object?> get props => [items];
}

class NotificationsStreamFailed extends NotificationEvent {
  const NotificationsStreamFailed();
}

class NotificationsMarkedRead extends NotificationEvent {
  final List<String> ids;
  const NotificationsMarkedRead(this.ids);

  @override
  List<Object?> get props => [ids];
}