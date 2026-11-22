import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/discover/domain/repositories/discover_repository.dart';
import 'package:skillswap/features/discover/domain/usecases/get_discover_profiles_usecase.dart';
import 'package:skillswap/features/matching/domain/entities/match_entity.dart';
import 'package:skillswap/features/matching/domain/usecases/match_finder.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

class GetMatchesUseCase {
  final DiscoverRepository repository;
  GetMatchesUseCase(this.repository);

  /// MVP : le matching tourne sur un nombre limité de profils chargés.
  Future<Either<Failure, List<MatchEntity>>> call({
    required ProfileEntity me,
  }) async {
    final result = await repository.fetchProfiles(
      limit: GetDiscoverProfilesUseCase.limit + 1,
    );
    return result.map<List<MatchEntity>>(
      (profiles) => MatchFinder.find(me, profiles),
    );
  }
}