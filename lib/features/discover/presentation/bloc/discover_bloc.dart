import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/discover/domain/usecases/get_discover_profiles_usecase.dart';
import 'package:skillswap/features/discover/domain/usecases/profile_filter.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

part 'discover_event.dart';
part 'discover_state.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final GetDiscoverProfilesUseCase getProfiles;

  DiscoverBloc({required this.getProfiles}) : super(const DiscoverLoading()) {
    on<DiscoverRequested>(_onRequested);
    on<DiscoverQueryChanged>(_onQueryChanged);
    on<DiscoverCategoryChanged>(_onCategoryChanged);
  }

  Future<void> _onRequested(
      DiscoverRequested event, Emitter<DiscoverState> emit) async {
    final previous = state;
    // Pendant un refresh, on garde la liste affichée.
    if (previous is! DiscoverLoaded) emit(const DiscoverLoading());

    try {
      final result = await getProfiles(myUid: event.uid);
      result.fold(
        (failure) => emit(DiscoverFailure(failure.message)),
        (profiles) {
          final query = previous is DiscoverLoaded ? previous.query : '';
          final category =
              previous is DiscoverLoaded ? previous.categoryId : null;
          emit(DiscoverLoaded(
            all: profiles,
            visible: ProfileFilter.apply(
              profiles,
              query: query,
              categoryId: category,
            ),
            query: query,
            categoryId: category,
          ));
        },
      );
    } finally {
      event.done?.complete();
    }
  }

  void _onQueryChanged(
      DiscoverQueryChanged event, Emitter<DiscoverState> emit) {
    final current = state;
    if (current is! DiscoverLoaded) return;
    emit(DiscoverLoaded(
      all: current.all,
      visible: ProfileFilter.apply(
        current.all,
        query: event.query,
        categoryId: current.categoryId,
      ),
      query: event.query,
      categoryId: current.categoryId,
    ));
  }

  void _onCategoryChanged(
      DiscoverCategoryChanged event, Emitter<DiscoverState> emit) {
    final current = state;
    if (current is! DiscoverLoaded) return;
    emit(DiscoverLoaded(
      all: current.all,
      visible: ProfileFilter.apply(
        current.all,
        query: current.query,
        categoryId: event.categoryId,
      ),
      query: current.query,
      categoryId: event.categoryId,
    ));
  }
}