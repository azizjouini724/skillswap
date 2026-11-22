import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/core/utils/format_utils.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/chat/domain/entities/chat_entity.dart';
import 'package:skillswap/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:skillswap/features/chat/presentation/widgets/chat_time.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          if (state is ChatListFailure) {
            return Center(child: Text(state.message));
          }
          if (state is! ChatListLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.chats.isEmpty) return const _Empty();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: state.chats.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) =>
                    _ChatTile(chat: state.chats[i], uid: uid),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatEntity chat;
  final String uid;
  const _ChatTile({required this.chat, required this.uid});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = chat.otherName(uid);
    final unread = chat.isUnreadFor(uid);
    final mine = chat.lastSenderId == uid;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.chat(chat.otherId(uid), name)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ProfileAvatar(
                  photoUrl: null, initials: initialsOf(name), radius: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          listTime(chat.lastMessageAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: unread
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mine ? 'You: ${chat.lastMessage}' : chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unread
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant,
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

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
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_bubble_outline_rounded,
                  size: 40, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            const Text('No conversation yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Open a profile from Discover and tap Message.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}