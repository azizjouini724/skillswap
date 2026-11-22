import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/chat/domain/entities/chat_entity.dart';
import 'package:skillswap/features/chat/domain/entities/message_entity.dart';
import 'package:skillswap/features/chat/domain/usecases/mark_chat_read_usecase.dart';
import 'package:skillswap/features/chat/domain/usecases/open_chat_usecase.dart';
import 'package:skillswap/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:skillswap/features/chat/domain/usecases/watch_chat_usecase.dart';
import 'package:skillswap/features/chat/domain/usecases/watch_messages_usecase.dart';

// Événements
abstract class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();

  @override
  List<Object?> get props => [];
}

class ChatRoomStarted extends ChatRoomEvent {
  final String uid;
  final String myName;
  final String otherUid;
  final String otherName;

  const ChatRoomStarted({
    required this.uid,
    required this.myName,
    required this.otherUid,
    required this.otherName,
  });

  @override
  List<Object?> get props => [uid, myName, otherUid, otherName];
}

class ChatRoomMessagesReceived extends ChatRoomEvent {
  final List<MessageEntity> items;
  const ChatRoomMessagesReceived(this.items);

  @override
  List<Object?> get props => [items];
}

class ChatRoomChatReceived extends ChatRoomEvent {
  final ChatEntity? chat;
  const ChatRoomChatReceived(this.chat);

  @override
  List<Object?> get props => [chat];
}

class ChatRoomStreamFailed extends ChatRoomEvent {
  const ChatRoomStreamFailed();
}

class ChatRoomSent extends ChatRoomEvent {
  final String text;
  const ChatRoomSent(this.text);

  @override
  List<Object?> get props => [text];
}

// États
abstract class ChatRoomState extends Equatable {
  const ChatRoomState();

  @override
  List<Object?> get props => [];
}

class ChatRoomLoading extends ChatRoomState {
  const ChatRoomLoading();
}

class ChatRoomLoaded extends ChatRoomState {
  final List<MessageEntity> messages;
  final DateTime? otherReadAt;

  const ChatRoomLoaded({required this.messages, this.otherReadAt});

  @override
  List<Object?> get props => [messages, otherReadAt];
}

class ChatRoomFailure extends ChatRoomState {
  final String message;
  const ChatRoomFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur ponctuelle (ex. envoi refusé), affichée en SnackBar.
class ChatRoomNotice extends ChatRoomState {
  final String message;
  const ChatRoomNotice(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final OpenChatUseCase openChat;
  final WatchChatUseCase watchChat;
  final WatchMessagesUseCase watchMessages;
  final SendMessageUseCase sendMessage;
  final MarkChatReadUseCase markChatRead;

  StreamSubscription<ChatEntity?>? _chatSub;
  StreamSubscription<List<MessageEntity>>? _messagesSub;

  String _uid = '';
  String _otherUid = '';
  String _chatId = '';
  ChatEntity? _chat;
  List<MessageEntity>? _messages;
  bool _marking = false;

  ChatRoomBloc({
    required this.openChat,
    required this.watchChat,
    required this.watchMessages,
    required this.sendMessage,
    required this.markChatRead,
  }) : super(const ChatRoomLoading()) {
    on<ChatRoomStarted>(_onStarted);
    on<ChatRoomMessagesReceived>((e, emit) {
      _messages = e.items;
      _emitLoaded(emit);
    });
    on<ChatRoomChatReceived>(_onChatReceived);
    on<ChatRoomStreamFailed>((e, emit) {
      emit(const ChatRoomFailure('Impossible de charger la conversation'));
    });
    on<ChatRoomSent>(_onSent);
  }

  Future<void> _onStarted(
      ChatRoomStarted e, Emitter<ChatRoomState> emit) async {
    _uid = e.uid;
    _otherUid = e.otherUid;
    _chatId = ChatEntity.idFor(e.uid, e.otherUid);
    _chat = null;
    _messages = null;
    emit(const ChatRoomLoading());

    final opened = await openChat(
      uid: e.uid,
      myName: e.myName,
      otherUid: e.otherUid,
      otherName: e.otherName,
    );
    if (opened.isLeft()) {
      emit(const ChatRoomFailure("Impossible d'ouvrir la conversation"));
      return;
    }

    await _chatSub?.cancel();
    await _messagesSub?.cancel();
    _chatSub = watchChat(_chatId).listen(
      (chat) => add(ChatRoomChatReceived(chat)),
      onError: (_) => add(const ChatRoomStreamFailed()),
    );
    _messagesSub = watchMessages(_chatId).listen(
      (items) => add(ChatRoomMessagesReceived(items)),
      onError: (_) => add(const ChatRoomStreamFailed()),
    );
  }

  Future<void> _onChatReceived(
      ChatRoomChatReceived e, Emitter<ChatRoomState> emit) async {
    _chat = e.chat;
    _emitLoaded(emit);

    // La conversation est ouverte : tout nouveau message est lu tout de suite.
    final chat = e.chat;
    if (chat != null && chat.isUnreadFor(_uid) && !_marking) {
      _marking = true;
      await markChatRead(chatId: _chatId, uid: _uid);
      _marking = false;
    }
  }

  void _emitLoaded(Emitter<ChatRoomState> emit) {
    final messages = _messages;
    if (messages == null) return;
    emit(ChatRoomLoaded(
      messages: messages,
      otherReadAt: _chat?.readAt[_otherUid],
    ));
  }

  Future<void> _onSent(ChatRoomSent e, Emitter<ChatRoomState> emit) async {
    final result = await sendMessage(
      chatId: _chatId,
      senderId: _uid,
      text: e.text,
    );
    result.fold(
      (failure) => emit(ChatRoomNotice(failure.message)),
      (_) {},
    );
    _emitLoaded(emit);
  }

  @override
  Future<void> close() {
    _chatSub?.cancel();
    _messagesSub?.cancel();
    return super.close();
  }
}