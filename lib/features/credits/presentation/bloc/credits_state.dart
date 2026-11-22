part of 'credits_bloc.dart';

abstract class CreditsState extends Equatable {
  const CreditsState();

  @override
  List<Object?> get props => [];
}

class CreditsLoading extends CreditsState {
  const CreditsLoading();
}

class CreditsLoaded extends CreditsState {
  final List<CreditTransaction> transactions;
  final int balance;
  final bool hasBonus;
  final String? notice;

  const CreditsLoaded({
    required this.transactions,
    required this.balance,
    required this.hasBonus,
    this.notice,
  });

  @override
  List<Object?> get props => [transactions, balance, hasBonus, notice];
}

class CreditsFailure extends CreditsState {
  final String message;
  const CreditsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
