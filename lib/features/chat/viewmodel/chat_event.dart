import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  final String profileType; // 'Customer' or 'Seller'

  const ChatStarted({required this.profileType});

  @override
  List<Object?> get props => [profileType];
}

class ChatConversationStartRequested extends ChatEvent {
  final int receiverProfileId;

  const ChatConversationStartRequested(this.receiverProfileId);

  @override
  List<Object?> get props => [receiverProfileId];
}

class ChatRoomOpened extends ChatEvent {
  final int conversationId;

  const ChatRoomOpened(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class ChatRoomClosed extends ChatEvent {
  const ChatRoomClosed();
}

class ChatMessageSent extends ChatEvent {
  final String body;

  const ChatMessageSent(this.body);

  @override
  List<Object?> get props => [body];
}

class ChatMarkReadRequested extends ChatEvent {
  final int conversationId;

  const ChatMarkReadRequested(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}
