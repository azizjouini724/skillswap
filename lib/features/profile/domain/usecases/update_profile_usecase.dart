import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String uid,
    required String name,
    required String bio,
    required String city,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      return const Left(ValidationFailure('Le nom est obligatoire'));
    }
    if (cleanName.length > 60) {
      return const Left(ValidationFailure('Nom trop long (60 max)'));
    }
    if (bio.trim().length > 200) {
      return const Left(ValidationFailure('Bio trop longue (200 max)'));
    }
    return repository.updateProfile(
      uid: uid,
      name: cleanName,
      bio: bio.trim(),
      city: city.trim(),
    );
  }
}