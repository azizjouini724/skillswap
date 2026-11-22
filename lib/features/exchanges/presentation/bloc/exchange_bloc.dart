import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/core/utils/format_utils.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';
import 'package:skillswap/features/exchanges/domain/usecases/counter_propose_session_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/propose_session_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/send_exchange_request_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/update_exchange_status_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/update_session_status_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/watch_exchanges_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/watch_sessions_usecase.dart';
import 'package:skillswap/features/notifications/domain/entities/notification_entity.dart';
import 'package:skillswap/features/notifications/domain/usecases/create_notification_usecase.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

part 'exchange_event.dart';
part 'exchange_state.dart';

class ExchangeBloc extends Bloc<ExchangeEvent, ExchangeState> {
  final WatchExchangesUseCase watchExchanges;
  final WatchSessionsUseCase watchSessions;
  final SendExchangeRequestUseCase sendRequest;
  final UpdateExchangeStatusUseCase updateExchangeStatus;
  final ProposeSessionUseCase proposeSession;
  final UpdateSessionStatusUseCase updateSessionStatus;
  final CounterProposeSessionUseCase counterProposeSession;
  final CreateNotificationUseCase createNotification;

  StreamSubscription<List<ExchangeEntity>>? _exchangesSub;
  StreamSubscription<List<SessionEntity>>? _sessionsSub;

  String _uid = '';
  List<ExchangeEntity>? _exchanges;
  List<SessionEntity>? _sessions;

  ExchangeBloc({
    required this.watchExchanges,
    required this.watchSessions,
    required this.sendRequest,
    required this.updateExchangeStatus,
    required this.proposeSession,
    required this.updateSessionStatus,
    required this.counterProposeSession,
    required this.createNotification,
  }) : super(const ExchangeLoading()) {
    on<ExchangesStarted>(_onStarted);
    on<ExchangesReceived>((e, emit) {
      _exchanges = e.items;
      _emitLoaded(emit);
    });
    on<SessionsReceived>((e, emit) {
      _sessions = e.items;
      _emitLoaded(emit);
    });
    on<ExchangesStreamFailed>((e, emit) {
      emit(const ExchangeFailure('Impossible de charger les échanges'));
    });
    on<ExchangeRequested>(_onRequested);
    on<ExchangeStatusChanged>(_onStatusChanged);
    on<SessionProposed>(_onSessionProposed);
    on<SessionStatusChanged>(_onSessionStatusChanged);
    on<SessionCounterProposed>(_onSessionCounterProposed);
  }

  Future<void> _onStarted(
      ExchangesStarted event, Emitter<ExchangeState> emit) async {
    _uid = event.uid;
    _exchanges = null;
    _sessions = null;
    emit(const ExchangeLoading());

    await _exchangesSub?.cancel();
    await _sessionsSub?.cancel();

    _exchangesSub = watchExchanges(_uid).listen(
      (items) => add(ExchangesReceived(items)),
      onError: (_) => add(const ExchangesStreamFailed()),
    );
    _sessionsSub = watchSessions(_uid).listen(
      (items) => add(SessionsReceived(items)),
      onError: (_) => add(const ExchangesStreamFailed()),
    );
  }

  void _emitLoaded(Emitter<ExchangeState> emit) {
    final exchanges = _exchanges;
    final sessions = _sessions;
    if (exchanges == null || sessions == null) return;
    emit(ExchangeLoaded(exchanges: exchanges, sessions: sessions));
  }

  /// Exécute l'action ; si elle réussit, envoie la notification (sans jamais
  /// faire échouer l'action si la notification échoue).
  Future<void> _run(
    Emitter<ExchangeState> emit,
    Future<Either<Failure, Unit>> Function() action,
    String successMessage, {
    Future<void> Function()? notify,
  }) async {
    final result = await action();
    var succeeded = false;
    result.fold(
      (failure) => emit(ExchangeNotice(failure.message, isError: true)),
      (_) {
        succeeded = true;
        emit(ExchangeNotice(successMessage));
      },
    );
    if (succeeded && notify != null) {
      try {
        await notify();
      } catch (_) {}
    }
    _emitLoaded(emit);
  }

  Future<void> _notify(
      String toUid, String type, String title, String body) async {
    await createNotification(
      toUid: toUid,
      fromUid: _uid,
      type: type,
      title: title,
      body: body,
    );
  }

  ExchangeEntity? _exchangeOf(SessionEntity session) =>
      (_exchanges ?? const <ExchangeEntity>[])
          .where((x) => x.id == session.exchangeId)
          .firstOrNull;

  Future<void> _onRequested(
      ExchangeRequested e, Emitter<ExchangeState> emit) {
    return _run(
      emit,
      () => sendRequest(
        me: e.me,
        other: e.other,
        offeredSkill: e.offeredSkill,
        requestedSkill: e.requestedSkill,
        message: e.message,
        existing: _exchanges ?? const [],
      ),
      'Request sent',
      notify: () => _notify(
        e.other.uid,
        NotificationType.request,
        'New exchange request',
        '${e.me.name} wants to swap ${e.offeredSkill} for ${e.requestedSkill}',
      ),
    );
  }

  Future<void> _onStatusChanged(
      ExchangeStatusChanged e, Emitter<ExchangeState> emit) {
    return _run(
      emit,
      () => updateExchangeStatus(
        exchange: e.exchange,
        uid: _uid,
        status: e.status,
      ),
      'Exchange updated',
      notify: () {
        final me = e.exchange.nameOf(_uid);
        final (title, body) = switch (e.status) {
          ExchangeStatus.accepted =>
            ('Request accepted', '$me accepted your exchange request'),
          ExchangeStatus.rejected =>
            ('Request declined', '$me declined your exchange request'),
          ExchangeStatus.cancelled =>
            ('Exchange cancelled', '$me cancelled the exchange'),
          ExchangeStatus.completed =>
            ('Exchange completed', '$me marked the exchange as completed'),
          _ => ('Exchange updated', '$me updated the exchange'),
        };
        return _notify(
          e.exchange.otherId(_uid),
          NotificationType.exchange,
          title,
          body,
        );
      },
    );
  }

  Future<void> _onSessionProposed(
      SessionProposed e, Emitter<ExchangeState> emit) {
    return _run(
      emit,
      () => proposeSession(
        exchange: e.exchange,
        uid: _uid,
        startAt: e.startAt,
        durationMinutes: e.durationMinutes,
        meetingMode: e.meetingMode,
      ),
      'Session proposed',
      notify: () => _notify(
        e.exchange.otherId(_uid),
        NotificationType.session,
        'Session proposed',
        '${e.exchange.nameOf(_uid)} proposed a session on '
            '${DateFmt.dateTime(e.startAt)}',
      ),
    );
  }

  Future<void> _onSessionStatusChanged(
      SessionStatusChanged e, Emitter<ExchangeState> emit) {
    return _run(
      emit,
      () => updateSessionStatus(
        session: e.session,
        uid: _uid,
        status: e.status,
      ),
      'Session updated',
      notify: () async {
        final ex = _exchangeOf(e.session);
        if (ex == null) return;
        final me = ex.nameOf(_uid);
        final (title, body) = switch (e.status) {
          SessionStatus.confirmed => (
              'Session confirmed',
              '$me confirmed the session on '
                  '${DateFmt.dateTime(e.session.startAt)}'
            ),
          SessionStatus.cancelled =>
            ('Session cancelled', '$me cancelled the session'),
          SessionStatus.completed =>
            ('Session completed', '$me marked the session as done'),
          _ => ('Session updated', '$me updated the session'),
        };
        await _notify(ex.otherId(_uid), NotificationType.session, title, body);
      },
    );
  }

  Future<void> _onSessionCounterProposed(
      SessionCounterProposed e, Emitter<ExchangeState> emit) {
    return _run(
      emit,
      () => counterProposeSession(
        session: e.session,
        uid: _uid,
        startAt: e.startAt,
        durationMinutes: e.durationMinutes,
        meetingMode: e.meetingMode,
      ),
      'New time proposed',
      notify: () async {
        final ex = _exchangeOf(e.session);
        if (ex == null) return;
        await _notify(
          ex.otherId(_uid),
          NotificationType.session,
          'New time suggested',
          '${ex.nameOf(_uid)} suggested ${DateFmt.dateTime(e.startAt)}',
        );
      },
    );
  }

  @override
  Future<void> close() {
    _exchangesSub?.cancel();
    _sessionsSub?.cancel();
    return super.close();
  }
}