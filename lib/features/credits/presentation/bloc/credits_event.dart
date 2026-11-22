part of 'credits_bloc.dart';

abstract class CreditsEvent extends Equatable {
  const CreditsEvent();

  @override
  List<Object?> get props => [];
}

class CreditsStarted extends CreditsEvent {
  final String uid;
  const CreditsStarted(this.uid);

  @override
  List<Object?> get props => [uid];
}

class CreditsTransactionsChanged extends CreditsEvent {
  final List<CreditTransaction> transactions;
  const CreditsTransactionsChanged(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class CreditsSessionsChanged extends CreditsEvent {
  final List<CompletedSessionRef> sessions;
  const CreditsSessionsChanged(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class CreditsStreamFailed extends CreditsEvent {
  const CreditsStreamFailed();
}

class CreditsBonusRequested extends CreditsEvent {
  final ProfileEntity profile;
  const CreditsBonusRequested(this.profile);

  @override
  List<Object?> get props => [profile];
}