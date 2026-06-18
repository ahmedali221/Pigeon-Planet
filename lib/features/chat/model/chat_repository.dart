import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'chat_conversation_model.dart';
import 'chat_message_model.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatConversationModel>>> listConversations();
  Future<Either<Failure, ChatConversationModel>> getOrCreateConversation(
      int receiverProfileId);
  Future<Either<Failure, List<ChatMessageModel>>> listMessages(
      int conversationId);
  Future<Either<Failure, List<ChatMessageModel>>> pollMessages(
      int conversationId, {int? afterId});
  Future<Either<Failure, ChatMessageModel>> sendMessage(
      int conversationId, String body);
  Future<Either<Failure, void>> markRead(int conversationId);
}
