import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../chat_conversation_model.dart';
import '../chat_message_model.dart';
import 'chat_remote_datasource.dart';

class RealChatRemoteDataSource implements ChatRemoteDataSource {
  final DioClient _dio;

  const RealChatRemoteDataSource(this._dio);

  @override
  Future<List<ChatConversationModel>> listConversations() async {
    try {
      final response = await _dio.get(ApiConstants.chatConversations);
      final data = response.data;
      final list = data is List
          ? data
          : (data is Map ? (data['results'] as List? ?? []) : []);
      return list
          .map((e) =>
              ChatConversationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحميل المحادثات');
    }
  }

  @override
  Future<ChatConversationModel> getOrCreateConversation(
      int receiverProfileId) async {
    try {
      final response = await _dio.post(
        ApiConstants.chatConversations,
        data: {'receiver_profile_id': receiverProfileId},
      );
      return ChatConversationModel.fromJson(
          response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل في بدء المحادثة');
    }
  }

  @override
  Future<List<ChatMessageModel>> listMessages(int conversationId) async {
    try {
      final response =
          await _dio.get(ApiConstants.chatMessages(conversationId));
      final data = response.data;
      final list = data is List
          ? data
          : (data is Map ? (data['results'] as List? ?? []) : []);
      return list
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحميل الرسائل');
    }
  }

  @override
  Future<List<ChatMessageModel>> pollMessages(int conversationId,
      {int? afterId}) async {
    try {
      final params = <String, dynamic>{if (afterId != null) 'after_id': afterId};
      final response = await _dio.get(
        ApiConstants.chatMessages(conversationId),
        queryParameters: params.isEmpty ? null : params,
      );
      final data = response.data;
      final list = data is List
          ? data
          : (data is Map ? (data['results'] as List? ?? []) : []);
      return list
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحديث الرسائل');
    }
  }

  @override
  Future<ChatMessageModel> sendMessage(
      int conversationId, String body) async {
    try {
      final response = await _dio.post(
        ApiConstants.chatMessages(conversationId),
        data: {'body': body},
      );
      return ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل في إرسال الرسالة');
    }
  }

  @override
  Future<void> markRead(int conversationId) async {
    try {
      await _dio.post(ApiConstants.chatMarkRead(conversationId));
    } on ApiException {
      rethrow;
    } catch (_) {
      // silence — mark-read failure should not interrupt UX
    }
  }
}
