import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/chat/domain/entities/chat_entity.dart';
import 'package:skillswap/features/chat/domain/usecases/watch_chats_usecase.dart';

// Événements
abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class ChatListStarted extends ChatListEvent {
  final String uid;
  const ChatListStarted(this.uid);

  @override
  List<Object?> get props => [uid];
}

class ChatListReceived extends ChatListEvent {
  final List<ChatEntity> chats;
  const ChatListReceived(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatListFailed extends ChatListEvent {
  const ChatListFailed();
}

// États
abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => [];
}

class ChatListLoading extends ChatListState {
  const ChatListLoading();
}

class ChatListLoaded extends ChatListState {
  final List<ChatEntity> chats;
  const ChatListLoaded(this.chats);

  int unreadCount(String uid) => chats.where((c) => c.isUnreadFor(uid)).length;

  @override
  List<Object?> get props => [chats];
}

class ChatListFailure extends ChatListState {
  final String message;
  const ChatListFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final WatchChatsUseCase watchChats;
  StreamSubscription<List<ChatEntity>>? _sub;

  ChatListBloc({required this.watchChats}) : super(const ChatListLoading()) {
    on<ChatListStarted>(_onStarted);
    on<ChatListReceived>((e, emit) => emit(ChatListLoaded(e.chats)));
    on<ChatListFailed>((e, emit) {
      emit(const ChatListFailure('Impossible de charger les messages'));
    });
  }

  Future<void> _onStarted(
      ChatListStarted event, Emitter<ChatListState> emit) async {
    emit(const ChatListLoading());
    await _sub?.cancel();
    _sub = watchChats(event.uid).listen(
      (chats) => add(ChatListReceived(chats)),
      onError: (_) => add(const ChatListFailed()),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}