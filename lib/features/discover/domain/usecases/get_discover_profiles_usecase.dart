import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/discover/domain/repositories/discover_repository.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

class GetDiscoverProfilesUseCase {
  static const limit = 50;

  final DiscoverRepository repository;
  GetDiscoverProfilesUseCase(this.repository);

  /// Autres utilisateurs, les plus complets en premier.
  Future<Either<Failure, List<ProfileEntity>>> call({
    required String myUid,
  }) async {
    final result = await repository.fetchProfiles(limit: limit + 1);

    return result.map<List<ProfileEntity>>((profiles) {
      final others = profiles
          .where((p) => p.uid != myUid && p.name.trim().isNotEmpty)
          .toList();

      others.sort((a, b) {
        final bySkills =
            (b.skillsToTeach.length + b.skillsToLearn.length).compareTo(
                a.skillsToTeach.length + a.skillsToLearn.length);
        if (bySkills != 0) return bySkills;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      return others;
    });
  }
}