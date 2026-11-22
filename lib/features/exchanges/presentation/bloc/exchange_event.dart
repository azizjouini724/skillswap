part of 'exchange_bloc.dart';

abstract class ExchangeEvent extends Equatable {
  const ExchangeEvent();

  @override
  List<Object?> get props => [];
}

class ExchangesStarted extends ExchangeEvent {
  final String uid;
  const ExchangesStarted(this.uid);

  @override
  List<Object?> get props => [uid];
}

class ExchangesReceived extends ExchangeEvent {
  final List<ExchangeEntity> items;
  const ExchangesReceived(this.items);

  @override
  List<Object?> get props => [items];
}

class SessionsReceived extends ExchangeEvent {
  final List<SessionEntity> items;
  const SessionsReceived(this.items);

  @override
  List<Object?> get props => [items];
}

class ExchangesStreamFailed extends ExchangeEvent {
  const ExchangesStreamFailed();
}

class ExchangeRequested extends ExchangeEvent {
  final ProfileEntity me;
  final ProfileEntity other;
  final String offeredSkill;
  final String requestedSkill;
  final String message;

  const ExchangeRequested({
    required this.me,
    required this.other,
    required this.offeredSkill,
    required this.requestedSkill,
    this.message = '',
  });

  @override
  List<Object?> get props =>
      [me, other, offeredSkill, requestedSkill, message];
}

class ExchangeStatusChanged extends ExchangeEvent {
  final ExchangeEntity exchange;
  final String status;
  const ExchangeStatusChanged({required this.exchange, required this.status});

  @override
  List<Object?> get props => [exchange, status];
}

class SessionProposed extends ExchangeEvent {
  final ExchangeEntity exchange;
  final DateTime startAt;
  final int durationMinutes;
  final String meetingMode;

  const SessionProposed({
    required this.exchange,
    required this.startAt,
    required this.durationMinutes,
    required this.meetingMode,
  });

  @override
  List<Object?> get props =>
      [exchange, startAt, durationMinutes, meetingMode];
}

class SessionStatusChanged extends ExchangeEvent {
  final SessionEntity session;
  final String status;
  const SessionStatusChanged({required this.session, required this.status});

  @override
  List<Object?> get props => [session, status];
}
class SessionCounterProposed extends ExchangeEvent {
  final SessionEntity session;
  final DateTime startAt;
  final int durationMinutes;
  final String meetingMode;

  const SessionCounterProposed({
    required this.session,
    required this.startAt,
    required this.durationMinutes,
    required this.meetingMode,
  });

  @override
  List<Object?> get props => [session, startAt, durationMinutes, meetingMode];
}