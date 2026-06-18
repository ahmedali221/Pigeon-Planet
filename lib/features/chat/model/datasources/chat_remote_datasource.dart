import '../chat_conversation_model.dart';
import '../chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatConversationModel>> listConversations();
  Future<ChatConversationModel> getOrCreateConversation(int receiverProfileId);
  Future<List<ChatMessageModel>> listMessages(int conversationId);
  Future<List<ChatMessageModel>> pollMessages(int conversationId, {int? afterId});
  Future<ChatMessageModel> sendMessage(int conversationId, String body);
  Future<void> markRead(int conversationId);
}
