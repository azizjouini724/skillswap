import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/repositories/exchange_repository.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/skills/domain/entities/skill_catalog.dart';

class SendExchangeRequestUseCase {
  static const maxMessage = 300;

  final ExchangeRepository repository;
  SendExchangeRequestUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required ProfileEntity me,
    required ProfileEntity other,
    required String offeredSkill,
    required String requestedSkill,
    String message = '',
    required List<ExchangeEntity> existing,
  }) async {
    if (me.uid == other.uid) {
      return const Left(
          ValidationFailure('Tu ne peux pas te proposer un échange'));
    }

    bool has(List<String> list, String s) => list
        .any((x) => SkillCatalog.normalize(x) == SkillCatalog.normalize(s));

    if (!has(me.skillsToTeach, offeredSkill)) {
      return const Left(
          ValidationFailure("Tu ne peux offrir qu'une compétence que tu enseignes"));
    }
    if (!has(other.skillsToTeach, requestedSkill)) {
      return const Left(
          ValidationFailure("Cette personne n'enseigne pas cette compétence"));
    }
    if (message.trim().length > maxMessage) {
      return const Left(ValidationFailure('Message trop long (300 max)'));
    }

    final alreadyPending = existing
        .any((e) => e.isPending && e.involves(me.uid) && e.involves(other.uid));
    if (alreadyPending) {
      return const Left(ValidationFailure(
          'Une demande est déjà en attente avec cette personne'));
    }

    return repository.sendRequest(
      senderId: me.uid,
      senderName: me.name,
      receiverId: other.uid,
      receiverName: other.name,
      offeredSkill: offeredSkill,
      requestedSkill: requestedSkill,
      message: message.trim(),
    );
  }
}