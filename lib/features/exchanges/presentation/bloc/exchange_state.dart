part of 'exchange_bloc.dart';

abstract class ExchangeState extends Equatable {
  const ExchangeState();

  @override
  List<Object?> get props => [];
}

class ExchangeLoading extends ExchangeState {
  const ExchangeLoading();
}

class ExchangeLoaded extends ExchangeState {
  final List<ExchangeEntity> exchanges;
  final List<SessionEntity> sessions;

  const ExchangeLoaded({required this.exchanges, required this.sessions});

  int pendingReceived(String uid) =>
      exchanges.where((e) => e.isPending && e.receiverId == uid).length;

  @override
  List<Object?> get props => [exchanges, sessions];
}

class ExchangeFailure extends ExchangeState {
  final String message;
  const ExchangeFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Message ponctuel (succès ou erreur d'une action), affiché en SnackBar
/// par MainShell, puis on réémet ExchangeLoaded.
class ExchangeNotice extends ExchangeState {
  final String message;
  final bool isError;
  const ExchangeNotice(this.message, {this.isError = false});

  @override
  List<Object?> get props => [message, isError];
}