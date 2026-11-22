part of 'match_bloc.dart';

abstract class MatchState extends Equatable {
  const MatchState();

  @override
  List<Object?> get props => [];
}

class MatchLoading extends MatchState {
  const MatchLoading();
}

class MatchLoaded extends MatchState {
  final List<MatchEntity> matches;
  const MatchLoaded(this.matches);

  @override
  List<Object?> get props => [matches];
}

class MatchFailure extends MatchState {
  final String message;
  const MatchFailure(this.message);

  @override
  List<Object?> get props => [message];
}