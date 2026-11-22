import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/features/credits/domain/entities/credit_ledger.dart';
import 'package:skillswap/features/credits/domain/entities/credit_transaction.dart';
import 'package:skillswap/features/credits/presentation/bloc/credits_bloc.dart';
import 'package:skillswap/features/profile/presentation/bloc/profile_bloc.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your credits')),
      body: BlocConsumer<CreditsBloc, CreditsState>(
        listenWhen: (_, state) => state is CreditsLoaded && state.notice != null,
        listener: (context, state) {
          if (state is CreditsLoaded && state.notice != null) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(SnackBar(content: Text(state.notice!)));
          }
        },
        builder: (context, state) {
          if (state is CreditsFailure) {
            return Center(child: Text(state.message));
          }
          if (state is! CreditsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _BalanceHero(balance: state.balance),
                    const SizedBox(height: 20),
                    if (!state.hasBonus) ...[
                      const _BonusCard(),
                      const SizedBox(height: 16),
                    ],
                    const _HowItWorks(),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent activity',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    _Activity(transactions: state.transactions),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  final int balance;
  const _BalanceHero({required this.balance});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.elasticOut,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: const Icon(Icons.star_rounded,
              size: 84, color: AppColors.warning),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: balance.toDouble()),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Text(
            '${value.round()}',
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800),
          ),
        ),
        Text('Available credits', style: TextStyle(color: muted)),
      ],
    );
  }
}

class _BonusCard extends StatelessWidget {
  const _BonusCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final profile = state is ProfileLoaded ? state.profile : null;
            final eligible = profile != null &&
                profile.hasBio &&
                profile.hasEnoughToTeach &&
                profile.hasEnoughToLearn;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.card_giftcard_rounded,
                          color: scheme.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Complete your profile',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          Text(
                            'Get ${CreditLedger.bonusAmount} bonus credits!',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (profile == null)
                  const LinearProgressIndicator()
                else if (eligible)
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<CreditsBloc>()
                        .add(CreditsBonusRequested(profile)),
                    icon: const Icon(Icons.redeem_rounded),
                    label: Text('Claim ${CreditLedger.bonusAmount} credits'),
                    style:
                        ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  )
                else ...[
                  _Check(done: profile.hasBio, label: 'Write a short bio'),
                  _Check(
                      done: profile.hasEnoughToTeach,
                      label: 'Add 2 skills you can teach'),
                  _Check(
                      done: profile.hasEnoughToLearn,
                      label: 'Add 2 skills you want to learn'),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  final bool done;
  final String label;
  const _Check({required this.done, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: done ? AppColors.success : AppColors.textLight,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: done ? AppColors.textLight : null,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF7A67F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'How it works?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _Rule(action: 'Teach a skill', reward: 'Earn 1 credit'),
          _Rule(action: 'Learn a skill', reward: 'Spend 1 credit'),
          _Rule(action: 'Complete your profile', reward: 'Get 50 bonus credits'),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final String action;
  final String reward;
  const _Rule({required this.action, required this.reward});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 20, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$action  →  $reward',
              style: const TextStyle(color: Colors.white, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _Activity extends StatelessWidget {
  final List<CreditTransaction> transactions;
  const _Activity({required this.transactions});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _date(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    if (transactions.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 36, color: muted),
              const SizedBox(height: 10),
              const Text('No activity yet',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                'Complete a session to see your first credits here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            _ActivityRow(
              transaction: transactions[i],
              date: _date(transactions[i].createdAt),
            ),
            if (i < transactions.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final CreditTransaction transaction;
  final String date;
  const _ActivityRow({required this.transaction, required this.date});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final delta = transaction.delta;
    final color = transaction.kind == CreditKind.bonus
        ? scheme.primary
        : delta > 0
            ? AppColors.success
            : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${delta > 0 ? '+' : ''}$delta',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              transaction.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(date,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }
}