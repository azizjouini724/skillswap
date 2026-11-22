part of 'discover_bloc.dart';

abstract class DiscoverState extends Equatable {
  const DiscoverState();

  @override
  List<Object?> get props => [];
}

class DiscoverLoading extends DiscoverState {
  const DiscoverLoading();
}

class DiscoverLoaded extends DiscoverState {
  final List<ProfileEntity> all;
  final List<ProfileEntity> visible;
  final String query;
  final String? categoryId;

  const DiscoverLoaded({
    required this.all,
    required this.visible,
    this.query = '',
    this.categoryId,
  });

  @override
  List<Object?> get props => [all, visible, query, categoryId];
}

class DiscoverFailure extends DiscoverState {
  final String message;
  const DiscoverFailure(this.message);

  @override
  List<Object?> get props => [message];
}