import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/stats/domain/entities/user_stats.dart';

class StatsCalculator {
  static const topLearnerSessions = 5;
  static const connectorPartners = 3;

  static UserStats compute({
    required String uid,
    required ProfileEntity? profile,
    required List<ExchangeEntity> exchanges,
    required List<SessionEntity> sessions,
  }) {
    final done = sessions
        .where((s) => s.involves(uid) && s.status == SessionStatus.completed)
        .toList();

    final exchangeById = {for (final e in exchanges) e.id: e};
    final partners = <String>{};
    for (final session in done) {
      final exchange = exchangeById[session.exchangeId];
      if (exchange == null) continue;
      partners.add(exchange.isSender(uid) ? exchange.receiverId : exchange.senderId);
    }

    final minutes = done.fold<int>(0, (sum, s) => sum + s.durationMinutes);

    final profileComplete = profile != null &&
        profile.hasBio &&
        profile.hasEnoughToTeach &&
        profile.hasEnoughToLearn;

    return UserStats(
      sessionsDone: done.length,
      minutes: minutes,
      partners: partners.length,
      badges: {
        if (profileComplete) AppBadge.swapReady,
        if (done.isNotEmpty) AppBadge.firstSwap,
        if (done.length >= topLearnerSessions) AppBadge.topLearner,
        if (partners.length >= connectorPartners) AppBadge.connector,
      },
    );
  }
}