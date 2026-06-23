import 'package:equatable/equatable.dart';

import '../model/chat_conversation_model.dart';
import '../model/chat_message_model.dart';

enum ChatStatus { initial, loading, loaded, error }

enum ChatRoomStatus { initial, loading, loaded, error }

enum ChatSendStatus { idle, sending, error }

class ChatState extends Equatable {
  final ChatStatus conversationsStatus;
  final List<ChatConversationModel> conversations;
  final String myProfileType; // 'Customer' or 'Seller'

  final ChatRoomStatus roomStatus;
  final int? activeConversationId;
  final List<ChatMessageModel> messages;

  final ChatSendStatus sendStatus;
  final String? sendError;
  final String? errorMessage;
  final bool requiresFollow;

  const ChatState({
    this.conversationsStatus = ChatStatus.initial,
    this.conversations = const [],
    this.myProfileType = 'Customer',
    this.roomStatus = ChatRoomStatus.initial,
    this.activeConversationId,
    this.messages = const [],
    this.sendStatus = ChatSendStatus.idle,
    this.sendError,
    this.errorMessage,
    this.requiresFollow = false,
  });

  int myProfileIdFor(ChatConversationModel conv) =>
      myProfileType == 'Customer' ? conv.customerId : conv.sellerId;

  String partnerNicknameFor(ChatConversationModel conv) =>
      myProfileType == 'Customer' ? conv.sellerNickname : conv.customerNickname;

  ChatConversationModel? get activeConversation =>
      activeConversationId == null
          ? null
          : conversations.where((c) => c.id == activeConversationId).firstOrNull;

  ChatState copyWith({
    ChatStatus? conversationsStatus,
    List<ChatConversationModel>? conversations,
    String? myProfileType,
    ChatRoomStatus? roomStatus,
    int? activeConversationId,
    List<ChatMessageModel>? messages,
    bool clearMessages = false,
    ChatSendStatus? sendStatus,
    String? sendError,
    bool clearSendError = false,
    String? errorMessage,
    bool? requiresFollow,
  }) {
    return ChatState(
      conversationsStatus: conversationsStatus ?? this.conversationsStatus,
      conversations: conversations ?? this.conversations,
      myProfileType: myProfileType ?? this.myProfileType,
      roomStatus: roomStatus ?? this.roomStatus,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      messages: clearMessages ? [] : (messages ?? this.messages),
      sendStatus: sendStatus ?? this.sendStatus,
      sendError: clearSendError ? null : (sendError ?? this.sendError),
      errorMessage: errorMessage ?? this.errorMessage,
      requiresFollow: requiresFollow ?? this.requiresFollow,
    );
  }

  @override
  List<Object?> get props => [
        conversationsStatus,
        conversations,
        myProfileType,
        roomStatus,
        activeConversationId,
        messages,
        sendStatus,
        sendError,
        errorMessage,
        requiresFollow,
      ];
}
