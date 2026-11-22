import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';
import 'package:skillswap/features/exchanges/domain/usecases/propose_session_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/send_exchange_request_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/update_exchange_status_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/update_session_status_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/watch_exchanges_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/watch_sessions_usecase.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/exchanges/domain/usecases/counter_propose_session_usecase.dart';

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

  Future<void> _run(
    Emitter<ExchangeState> emit,
    Future<Either<Failure, Unit>> Function() action,
    String successMessage,
  ) async {
    final result = await action();
    result.fold(
      (failure) => emit(ExchangeNotice(failure.message, isError: true)),
      (_) => emit(ExchangeNotice(successMessage)),
    );
    _emitLoaded(emit);
  }

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
    );
  }

  @override
  Future<void> close() {
    _exchangesSub?.cancel();
    _sessionsSub?.cancel();
    return super.close();
  }
}