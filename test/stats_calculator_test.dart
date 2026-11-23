import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/stats/domain/entities/user_stats.dart';
import 'package:skillswap/features/stats/domain/usecases/stats_calculator.dart';

ExchangeEntity exchange(String id, String other) => ExchangeEntity(
      id: id,
      senderId: 'me',
      receiverId: other,
      senderName: 'Me',
      receiverName: other,
      offeredSkill: 'Flutter',
      requestedSkill: 'Photoshop',
      status: ExchangeStatus.accepted,
      createdAt: DateTime(2026, 11, 22),
    );

SessionEntity session(
  String id,
  String exchangeId, {
  int minutes = 60,
  String status = SessionStatus.completed,
}) =>
    SessionEntity(
      id: id,
      exchangeId: exchangeId,
      hostId: 'me',
      participantIds: const ['me', 'x'],
      startAt: DateTime(2026, 11, 22),
      durationMinutes: minutes,
      meetingMode: MeetingMode.online,
      status: status,
    );

UserStats compute(
  List<ExchangeEntity> exchanges,
  List<SessionEntity> sessions, {
  ProfileEntity? profile,
}) =>
    StatsCalculator.compute(
      uid: 'me',
      profile: profile,
      exchanges: exchanges,
      sessions: sessions,
    );

void main() {
  test('sans séance : aucun badge de séance', () {
    final stats = compute([], []);
    expect(stats.sessionsDone, 0);
    expect(stats.badges, isEmpty);
  });

  test('une séance terminée donne First Swap et compte les heures', () {
    final stats =
        compute([exchange('e1', 'sara')], [session('s1', 'e1', minutes: 90)]);
    expect(stats.sessionsDone, 1);
    expect(stats.minutes, 90);
    expect(stats.hours, 1.5);
    expect(stats.has(AppBadge.firstSwap), true);
  });

  test('les séances non terminées sont ignorées', () {
    final stats = compute([
      exchange('e1', 'sara')
    ], [
      session('s1', 'e1', status: SessionStatus.proposed),
      session('s2', 'e1', status: SessionStatus.cancelled),
    ]);
    expect(stats.sessionsDone, 0);
    expect(stats.has(AppBadge.firstSwap), false);
  });

  test('5 séances terminées donnent Top Learner', () {
    final stats = compute([
      exchange('e1', 'sara')
    ], [
      for (var i = 0; i < 5; i++) session('s$i', 'e1'),
    ]);
    expect(stats.has(AppBadge.topLearner), true);
  });

  test('un même partenaire ne compte qu\'une fois', () {
    final stats = compute([
      exchange('e1', 'sara')
    ], [
      session('s1', 'e1'),
      session('s2', 'e1'),
    ]);
    expect(stats.partners, 1);
    expect(stats.has(AppBadge.connector), false);
  });

  test('3 partenaires différents donnent Connector, profil complet Swap-ready',
      () {
    const profile = ProfileEntity(
      uid: 'me',
      name: 'Ahmed',
      email: 'a@a.com',
      bio: 'Flutter student',
      skillsToTeach: ['Flutter', 'Dart'],
      skillsToLearn: ['Photoshop', 'UI/UX Design'],
    );
    final stats = compute(
      [exchange('e1', 'sara'), exchange('e2', 'youssef'), exchange('e3', 'nadia')],
      [session('s1', 'e1'), session('s2', 'e2'), session('s3', 'e3')],
      profile: profile,
    );
    expect(stats.partners, 3);
    expect(stats.has(AppBadge.connector), true);
    expect(stats.has(AppBadge.swapReady), true);
  });
}