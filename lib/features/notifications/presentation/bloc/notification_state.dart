part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> items;
  const NotificationLoaded(this.items);

  int get unreadCount => items.where((n) => !n.isRead).length;
  List<String> get unreadIds =>
      items.where((n) => !n.isRead).map((n) => n.id).toList();

  @override
  List<Object?> get props => [items];
}

class NotificationFailure extends NotificationState {
  final String message;
  const NotificationFailure(this.message);

  @override
  List<Object?> get props => [message];
}