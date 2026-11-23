import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';

abstract class PresenceRepository {
  Future<Either<Failure, Unit>> touch(String uid);
}