import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/matching/domain/entities/match_entity.dart';
import 'package:skillswap/features/matching/domain/usecases/get_matches_usecase.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

part 'match_event.dart';
part 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final GetMatchesUseCase getMatches;

  MatchBloc({required this.getMatches}) : super(const MatchLoading()) {
    on<MatchRequested>(_onRequested);
  }

  Future<void> _onRequested(
      MatchRequested event, Emitter<MatchState> emit) async {
    // Pendant un refresh, on garde la liste affichée.
    if (state is! MatchLoaded) emit(const MatchLoading());

    try {
      final result = await getMatches(me: event.me);
      result.fold(
        (failure) => emit(MatchFailure(failure.message)),
        (matches) => emit(MatchLoaded(matches)),
      );
    } finally {
      event.done?.complete();
    }
  }
}