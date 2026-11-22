import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/profile/domain/repositories/profile_repository.dart';

class UpdatePhotoUseCase {
  static const maxBytes = 100 * 1024;

  final ProfileRepository repository;
  UpdatePhotoUseCase(this.repository);

  /// bytes == null : supprime la photo.
  Future<Either<Failure, Unit>> call({
    required String uid,
    Uint8List? bytes,
  }) async {
    if (bytes == null) {
      return repository.updatePhoto(uid: uid, photo: null);
    }
    if (bytes.isEmpty) {
      return const Left(ValidationFailure('Image invalide'));
    }
    if (bytes.length > maxBytes) {
      return const Left(
          ValidationFailure('Image trop lourde (100 Ko max), choisis-en une plus petite'));
    }
    return repository.updatePhoto(
      uid: uid,
      photo: 'data:image/jpeg;base64,${base64Encode(bytes)}',
    );
  }
}