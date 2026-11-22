import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/utils/format_utils.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/chat/domain/entities/message_entity.dart';
import 'package:skillswap/features/chat/presentation/bloc/chat_room_bloc.dart';
import 'package:skillswap/features/chat/presentation/widgets/chat_time.dart';
import 'package:skillswap/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:skillswap/injection_container.dart';

class ChatPage extends StatelessWidget {
  final String otherUid;
  final String otherName;
  const ChatPage({super.key, required this.otherUid, required this.otherName});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().currentUser?.uid ?? '';
    final myName = context.read<ProfileBloc>().profile?.name ?? '';

    return BlocProvider(
      create: (_) => sl<ChatRoomBloc>()
        ..add(ChatRoomStarted(
          uid: uid,
          myName: myName,
          otherUid: otherUid,
          otherName: otherName,
        )),
      child: _ChatView(uid: uid, otherName: otherName),
    );
  }
}

class _ChatView extends StatefulWidget {
  final String uid;
  final String otherName;
  const _ChatView({required this.uid, required this.otherName});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatRoomBloc>().add(ChatRoomSent(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ProfileAvatar(
              photoUrl: null,
              initials: initialsOf(widget.otherName),
              radius: 17,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.otherName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatRoomBloc, ChatRoomState>(
              listenWhen: (_, state) => state is ChatRoomNotice,
              listener: (context, state) {
                if (state is ChatRoomNotice) {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.hideCurrentSnackBar();
                  messenger.showSnackBar(SnackBar(
                    content: Text(state.message),
                    backgroundColor: scheme.error,
                  ));
                }
              },
              buildWhen: (_, state) => state is! ChatRoomNotice,
              builder: (context, state) {
                if (state is ChatRoomFailure) {
                  return Center(child: Text(state.message));
                }
                if (state is! ChatRoomLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Say hello to ${widget.otherName.split(' ').first}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  );
                }
                return _MessageList(
                  messages: state.messages,
                  uid: widget.uid,
                  otherReadAt: state.otherReadAt,
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final List<MessageEntity> messages;
  final String uid;
  final DateTime? otherReadAt;

  const _MessageList({
    required this.messages,
    required this.uid,
    required this.otherReadAt,
  });

  @override
  Widget build(BuildContext context) {
    // Mon dernier message : c'est lui qui affiche « Seen ».
        final lastMine = messages.lastWhere(
      (m) => m.senderId == uid,
      orElse: () => MessageEntity(
        id: '',
        senderId: '',
        text: '',
        createdAt: DateTime(2000),
      ),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView.builder(
          reverse: true,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          itemCount: messages.length,
          itemBuilder: (context, i) {
            final m = messages[messages.length - 1 - i];
            final mine = m.senderId == uid;
            final seen = mine &&
                m.id == lastMine.id &&
                otherReadAt != null &&
                !otherReadAt!.isBefore(m.createdAt);
            return _Bubble(message: m, mine: mine, seen: seen);
          },
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final MessageEntity message;
  final bool mine;
  final bool seen;
  const _Bubble({
    required this.message,
    required this.mine,
    required this.seen,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxWidth = (MediaQuery.of(context).size.width * 0.75).clamp(0.0, 460.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? scheme.primary : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(mine ? 18 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 18),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: mine ? scheme.onPrimary : scheme.onSurface,
                  height: 1.35,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            seen ? '${clock(message.createdAt)}  ·  Seen' : clock(message.createdAt),
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}