import 'package:equatable/equatable.dart';

class NotificationType {
  static const request = 'request';
  static const exchange = 'exchange';
  static const session = 'session';
}

class NotificationEntity extends Equatable {
  final String id;
  final String toUid;
  final String fromUid;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.toUid,
    required this.fromUid,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, toUid, fromUid, type, title, body, isRead, createdAt];
}