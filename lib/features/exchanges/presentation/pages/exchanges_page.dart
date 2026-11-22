import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/presentation/bloc/exchange_bloc.dart';
import 'package:skillswap/features/exchanges/presentation/widgets/exchange_card.dart';
import 'package:skillswap/features/exchanges/presentation/widgets/plan_session_sheet.dart';
import 'package:skillswap/features/exchanges/presentation/widgets/session_card.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';

class ExchangesPage extends StatelessWidget {
  const ExchangesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().currentUser?.uid ?? '';

    return BlocBuilder<ExchangeBloc, ExchangeState>(
      buildWhen: (_, state) => state is! ExchangeNotice,
      builder: (context, state) {
        final loaded = state is ExchangeLoaded ? state : null;
        final received =
            loaded?.exchanges.where((e) => e.receiverId == uid).toList() ?? [];
        final sent =
            loaded?.exchanges.where((e) => e.senderId == uid).toList() ?? [];
        final pending = loaded?.pendingReceived(uid) ?? 0;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Exchanges'),
              bottom: TabBar(
                tabs: [
                  Tab(text: pending > 0 ? 'Received ($pending)' : 'Received'),
                  const Tab(text: 'Sent'),
                  const Tab(text: 'Sessions'),
                ],
              ),
            ),
            body: Builder(builder: (context) {
              if (state is ExchangeFailure) {
                return _Empty(
                  icon: Icons.cloud_off_rounded,
                  title: 'Something went wrong',
                  subtitle: state.message,
                );
              }
              if (loaded == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return TabBarView(
                children: [
                  _ExchangeList(
                    items: received,
                    uid: uid,
                    emptyTitle: 'No request received',
                    emptySubtitle:
                        'When someone asks to swap skills with you, it shows up here.',
                  ),
                  _ExchangeList(
                    items: sent,
                    uid: uid,
                    emptyTitle: 'No request sent',
                    emptySubtitle:
                        'Open a profile from Discover or Smart Match to request an exchange.',
                  ),
                  _SessionList(state: loaded, uid: uid),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

Future<void> _planSession(BuildContext context, ExchangeEntity exchange) async {
  final uid = context.read<AuthBloc>().currentUser?.uid ?? '';
  final draft = await showModalBottomSheet<SessionDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => PlanSessionSheet(otherName: exchange.otherName(uid)),
  );
  if (draft != null && context.mounted) {
    context.read<ExchangeBloc>().add(SessionProposed(
          exchange: exchange,
          startAt: draft.startAt,
          durationMinutes: draft.durationMinutes,
          meetingMode: draft.meetingMode,
        ));
  }
}
Future<void> _counterPropose(
    BuildContext context, SessionEntity session, String otherName) async {
  final draft = await showModalBottomSheet<SessionDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => PlanSessionSheet(otherName: otherName, counter: true),
  );
  if (draft != null && context.mounted) {
    context.read<ExchangeBloc>().add(SessionCounterProposed(
          session: session,
          startAt: draft.startAt,
          durationMinutes: draft.durationMinutes,
          meetingMode: draft.meetingMode,
        ));
  }
}

class _ExchangeList extends StatelessWidget {
  final List<ExchangeEntity> items;
  final String uid;
  final String emptyTitle;
  final String emptySubtitle;

  const _ExchangeList({
    required this.items,
    required this.uid,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _Empty(
        icon: Icons.swap_horiz_rounded,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final exchange = items[index];
            return ExchangeCard(
              exchange: exchange,
              uid: uid,
              onStatus: (status) => context.read<ExchangeBloc>().add(
                    ExchangeStatusChanged(exchange: exchange, status: status),
                  ),
              onPlanSession: () => _planSession(context, exchange),
            );
          },
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  final ExchangeLoaded state;
  final String uid;
  const _SessionList({required this.state, required this.uid});

  @override
  Widget build(BuildContext context) {
    if (state.sessions.isEmpty) {
      return const _Empty(
        icon: Icons.event_busy_outlined,
        title: 'No session yet',
        subtitle:
            'Once an exchange is accepted, plan a session from the Received or Sent tab.',
      );
    }

    final upcoming = state.sessions.where((s) => s.isUpcoming).toList();
    final past = state.sessions.where((s) => !s.isUpcoming).toList().reversed;
    final byId = {for (final e in state.exchanges) e.id: e};
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    Widget card(session) {
      final exchange = byId[session.exchangeId];
      return SessionCard(
        session: session,
        uid: uid,
        title: exchange == null
            ? 'Session'
            : 'With ${exchange.otherName(uid)}',
        subtitle: exchange == null
            ? ''
            : '${exchange.teachOf(uid)}  ·  ${exchange.learnOf(uid)}',
        onStatus: (status) => context.read<ExchangeBloc>().add(
              SessionStatusChanged(session: session, status: status),
            ),
              
        onCounter: () => _counterPropose(
          context,
          session,
          exchange == null ? '' : exchange.otherName(uid),
        ),
      );
    }

    Widget header(String text) => Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: muted,
            ),
          ),
        );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            if (upcoming.isNotEmpty) ...[
              header('Upcoming'),
              for (final s in upcoming) ...[card(s), const SizedBox(height: 14)],
            ],
            if (past.isNotEmpty) ...[
              header('Past'),
              for (final s in past) ...[card(s), const SizedBox(height: 14)],
            ],
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Empty({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4)),
          ],
        ),
      ),
    );
  }
}