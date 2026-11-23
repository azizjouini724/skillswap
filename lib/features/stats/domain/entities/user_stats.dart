import 'package:equatable/equatable.dart';

enum AppBadge { swapReady, firstSwap, topLearner, connector }

class UserStats extends Equatable {
  final int sessionsDone;
  final int minutes;
  final int partners;
  final Set<AppBadge> badges;

  const UserStats({
    required this.sessionsDone,
    required this.minutes,
    required this.partners,
    required this.badges,
  });

  double get hours => minutes / 60;
  bool has(AppBadge badge) => badges.contains(badge);

  @override
  List<Object?> get props => [sessionsDone, minutes, partners, badges];
}