part of 'match_bloc.dart';

abstract class MatchEvent extends Equatable {
  const MatchEvent();

  @override
  List<Object?> get props => [];
}

/// Chargement initial ou pull-to-refresh.
class MatchRequested extends MatchEvent {
  final ProfileEntity me;
  final Completer<void>? done;
  const MatchRequested(this.me, {this.done});

  @override
  List<Object?> get props => [me];
}