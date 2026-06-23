import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../model/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

export 'chat_event.dart';
export 'chat_state.dart';

// Internal polling ticks — defined here so they stay private to this file.
class _PollTick extends ChatEvent {
  const _PollTick();
}

class _ConversationsPollTick extends ChatEvent {
  const _ConversationsPollTick();
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  Timer? _pollTimer;
  Timer? _conversationsPollTimer;

  ChatBloc({required ChatRepository repository})
      : _repository = repository,
        super(const ChatState()) {
    on<ChatStarted>(_onStarted);
    on<ChatConversationStartRequested>(_onStartConversation);
    on<ChatRoomOpened>(_onRoomOpened);
    on<ChatRoomClosed>(_onRoomClosed);
    on<_PollTick>(_onPollTick);
    on<_ConversationsPollTick>(_onConversationsPollTick);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatMarkReadRequested>(_onMarkRead);
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _conversationsPollTimer?.cancel();
    return super.close();
  }

  Future<void> _onStarted(ChatStarted e, Emitter<ChatState> emit) async {
    emit(state.copyWith(
      conversationsStatus: ChatStatus.loading,
      myProfileType: e.profileType,
    ));
    final result = await _repository.listConversations();
    result.fold(
      (f) => emit(state.copyWith(
        conversationsStatus: ChatStatus.error,
        errorMessage: f.message,
      )),
      (convs) {
        emit(state.copyWith(
          conversationsStatus: ChatStatus.loaded,
          conversations: convs,
        ));
        _conversationsPollTimer?.cancel();
        _conversationsPollTimer = Timer.periodic(
          const Duration(seconds: 30),
          (_) { if (!isClosed) add(const _ConversationsPollTick()); },
        );
      },
    );
  }

  Future<void> _onConversationsPollTick(
      _ConversationsPollTick e, Emitter<ChatState> emit) async {
    final result = await _repository.listConversations();
    result.fold(
      (_) {},
      (convs) => emit(state.copyWith(conversations: convs)),
    );
  }

  Future<void> _onStartConversation(
      ChatConversationStartRequested e, Emitter<ChatState> emit) async {
    emit(state.copyWith(roomStatus: ChatRoomStatus.loading));
    final result = await _repository.getOrCreateConversation(e.receiverProfileId);
    result.fold(
      (f) {
        final isFollowGate = f is ValidationFailure &&
            f.message.toLowerCase().contains('follow');
        emit(state.copyWith(
          roomStatus: ChatRoomStatus.error,
          errorMessage: f.message,
          requiresFollow: isFollowGate,
        ));
      },
      (conv) {
        final exists = state.conversations.any((c) => c.id == conv.id);
        final updated =
            exists ? state.conversations : [conv, ...state.conversations];
        emit(state.copyWith(
          conversations: updated,
          activeConversationId: conv.id,
        ));
        add(ChatRoomOpened(conv.id));
      },
    );
  }

  Future<void> _onRoomOpened(
      ChatRoomOpened e, Emitter<ChatState> emit) async {
    _pollTimer?.cancel();
    _pollTimer = null;
    emit(state.copyWith(
      activeConversationId: e.conversationId,
      roomStatus: ChatRoomStatus.loading,
      clearMessages: true,
    ));
    final result = await _repository.listMessages(e.conversationId);
    result.fold(
      (f) => emit(state.copyWith(
        roomStatus: ChatRoomStatus.error,
        errorMessage: f.message,
      )),
      (msgs) {
        emit(state.copyWith(
          roomStatus: ChatRoomStatus.loaded,
          messages: msgs,
        ));
        _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (!isClosed) add(const _PollTick());
        });
        if (!isClosed) add(ChatMarkReadRequested(e.conversationId));
      },
    );
  }

  Future<void> _onRoomClosed(
      ChatRoomClosed e, Emitter<ChatState> emit) async {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _onPollTick(
      _PollTick e, Emitter<ChatState> emit) async {
    final convId = state.activeConversationId;
    if (convId == null) return;
    final afterId = state.messages.isEmpty ? null : state.messages.last.id;
    final result =
        await _repository.pollMessages(convId, afterId: afterId);
    result.fold(
      (_) {}, // silent poll failure
      (newMsgs) {
        if (newMsgs.isEmpty) return;
        emit(state.copyWith(
          messages: [...state.messages, ...newMsgs],
        ));
        if (!isClosed) add(ChatMarkReadRequested(convId));
      },
    );
  }

  Future<void> _onMessageSent(
      ChatMessageSent e, Emitter<ChatState> emit) async {
    final convId = state.activeConversationId;
    if (convId == null || e.body.trim().isEmpty) return;
    emit(state.copyWith(
      sendStatus: ChatSendStatus.sending,
      clearSendError: true,
    ));
    final result = await _repository.sendMessage(convId, e.body.trim());
    result.fold(
      (f) => emit(state.copyWith(
        sendStatus: ChatSendStatus.error,
        sendError: f.message,
      )),
      (msg) => emit(state.copyWith(
        sendStatus: ChatSendStatus.idle,
        messages: [...state.messages, msg],
      )),
    );
  }

  Future<void> _onMarkRead(
      ChatMarkReadRequested e, Emitter<ChatState> emit) async {
    await _repository.markRead(e.conversationId);
    final updated = state.conversations
        .map((c) => c.id == e.conversationId ? c.copyWith(unreadCount: 0) : c)
        .toList();
    emit(state.copyWith(conversations: updated));
  }
}
