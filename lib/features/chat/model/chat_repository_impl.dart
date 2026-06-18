import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'chat_conversation_model.dart';
import 'chat_message_model.dart';
import 'chat_repository.dart';
import 'datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _dataSource;

  const ChatRepositoryImpl(this._dataSource);

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ForbiddenException) return ForbiddenFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    return ServerFailure(e.message);
  }

  @override
  Future<Either<Failure, List<ChatConversationModel>>>
      listConversations() async {
    try {
      return Right(await _dataSource.listConversations());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ChatConversationModel>> getOrCreateConversation(
      int receiverProfileId) async {
    try {
      return Right(await _dataSource.getOrCreateConversation(receiverProfileId));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageModel>>> listMessages(
      int conversationId) async {
    try {
      return Right(await _dataSource.listMessages(conversationId));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageModel>>> pollMessages(
      int conversationId, {int? afterId}) async {
    try {
      return Right(
          await _dataSource.pollMessages(conversationId, afterId: afterId));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ChatMessageModel>> sendMessage(
      int conversationId, String body) async {
    try {
      return Right(await _dataSource.sendMessage(conversationId, body));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markRead(int conversationId) async {
    try {
      await _dataSource.markRead(conversationId);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
