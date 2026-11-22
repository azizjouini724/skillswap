import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

abstract class DiscoverRepository {
  Future<Either<Failure, List<ProfileEntity>>> fetchProfiles({
    required int limit,
  });
}