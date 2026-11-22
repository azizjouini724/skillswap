part of 'discover_bloc.dart';

abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();

  @override
  List<Object?> get props => [];
}

/// Chargement initial ou pull-to-refresh. `done` permet au
/// RefreshIndicator d'attendre la fin du chargement.
class DiscoverRequested extends DiscoverEvent {
  final String uid;
  final Completer<void>? done;
  const DiscoverRequested(this.uid, {this.done});

  @override
  List<Object?> get props => [uid];
}

class DiscoverQueryChanged extends DiscoverEvent {
  final String query;
  const DiscoverQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class DiscoverCategoryChanged extends DiscoverEvent {
  final String? categoryId;
  const DiscoverCategoryChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}