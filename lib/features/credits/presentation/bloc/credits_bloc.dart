import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/credits/domain/entities/completed_session_ref.dart';
import 'package:skillswap/features/credits/domain/entities/credit_ledger.dart';
import 'package:skillswap/features/credits/domain/entities/credit_transaction.dart';
import 'package:skillswap/features/credits/domain/usecases/credits_usecases.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

part 'credits_event.dart';
part 'credits_state.dart';

class CreditsBloc extends Bloc<CreditsEvent, CreditsState> {
  final WatchTransactionsUseCase watchTransactions;
  final WatchCompletedSessionsUseCase watchCompletedSessions;
  final ClaimProfileBonusUseCase claimBonus;
  final ClaimSessionCreditsUseCase claimSession;

  StreamSubscription<List<CreditTransaction>>? _transactionsSub;
  StreamSubscription<List<CompletedSessionRef>>? _sessionsSub;

  String? _uid;
  List<CreditTransaction> _transactions = const [];
  List<CompletedSessionRef> _sessions = const [];
  bool _transactionsReady = false;

  /// Séances déjà tentées : évite de réécrire en boucle en cas d'échec.
  final Set<String> _attempted = {};

  CreditsBloc({
    required this.watchTransactions,
    required this.watchCompletedSessions,
    required this.claimBonus,
    required this.claimSession,
  }) : super(const CreditsLoading()) {
    on<CreditsStarted>(_onStarted);
    on<CreditsTransactionsChanged>(_onTransactions);
    on<CreditsSessionsChanged>(_onSessions);
    on<CreditsStreamFailed>(_onFailed);
    on<CreditsBonusRequested>(_onBonus);
  }

  Future<void> _onStarted(
      CreditsStarted event, Emitter<CreditsState> emit) async {
    emit(const CreditsLoading());
    await _transactionsSub?.cancel();
    await _sessionsSub?.cancel();

    _uid = event.uid;
    _transactions = const [];
    _sessions = const [];
    _transactionsReady = false;
    _attempted.clear();

    _transactionsSub = watchTransactions(event.uid).listen(
      (t) => add(CreditsTransactionsChanged(t)),
      onError: (_) => add(const CreditsStreamFailed()),
    );
    _sessionsSub = watchCompletedSessions(event.uid).listen(
      (s) => add(CreditsSessionsChanged(s)),
      onError: (_) => add(const CreditsStreamFailed()),
    );
  }

  Future<void> _onTransactions(
      CreditsTransactionsChanged event, Emitter<CreditsState> emit) async {
    _transactions = event.transactions;
    _transactionsReady = true;
    emit(_loaded());
    await _claimMissing();
  }

  Future<void> _onSessions(
      CreditsSessionsChanged event, Emitter<CreditsState> emit) async {
    _sessions = event.sessions;
    await _claimMissing();
  }

  void _onFailed(CreditsStreamFailed event, Emitter<CreditsState> emit) {
    emit(const CreditsFailure('Unable to load your credits'));
  }

  Future<void> _onBonus(
      CreditsBonusRequested event, Emitter<CreditsState> emit) async {
    final result = await claimBonus(event.profile);
    result.fold(
      (failure) => emit(_loaded(notice: failure.message)),
      (_) => emit(_loaded(notice: 'You earned ${CreditLedger.bonusAmount} credits')),
    );
  }

  /// Crée mes mouvements pour les séances terminées pas encore créditées.
  Future<void> _claimMissing() async {
    final uid = _uid;
    if (uid == null || !_transactionsReady) return;

    final missing = CreditLedger.unclaimed(
      uid: uid,
      sessions: _sessions,
      transactions: _transactions,
    );
    for (final session in missing) {
      if (!_attempted.add(session.id)) continue;
      await claimSession(uid: uid, session: session);
    }
  }

  CreditsLoaded _loaded({String? notice}) {
    final sorted = [..._transactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return CreditsLoaded(
      transactions: sorted,
      balance: CreditLedger.balance(sorted),
      hasBonus: CreditLedger.hasBonus(sorted),
      notice: notice,
    );
  }

  @override
  Future<void> close() {
    _transactionsSub?.cancel();
    _sessionsSub?.cancel();
    return super.close();
  }
}