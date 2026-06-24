import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'datasources/payments_remote_datasource.dart';
import 'payment_request_model.dart';
import 'payments_repository.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource _dataSource;

  const PaymentsRepositoryImpl(this._dataSource);

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    if (e is ForbiddenException) return ForbiddenFailure(e.message);
    return ServerFailure(e.message);
  }

  @override
  Future<Either<Failure, List<PaymentRequestModel>>> getPaymentRequests() async {
    try {
      return Right(await _dataSource.getPaymentRequests());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentRequestModel>> createAuctionPaymentRequest(
    int auctionItemId, {
    String? buyerNote,
    PlatformFile? proofFile,
  }) async {
    try {
      return Right(await _dataSource.createAuctionPaymentRequest(
        auctionItemId,
        buyerNote: buyerNote,
        proofFile: proofFile,
      ));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentRequestModel>> createMarketPaymentRequest(
    int orderItemId, {
    String? buyerNote,
    PlatformFile? proofFile,
  }) async {
    try {
      return Right(await _dataSource.createMarketPaymentRequest(
        orderItemId,
        buyerNote: buyerNote,
        proofFile: proofFile,
      ));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentRequestModel>> updateBuyerNote(
    int requestId,
    String buyerNote, {
    PlatformFile? proofFile,
  }) async {
    try {
      return Right(await _dataSource.updateBuyerNote(
        requestId,
        buyerNote,
        proofFile: proofFile,
      ));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentRequestModel>> approvePaymentRequest(
    int requestId,
  ) async {
    try {
      return Right(await _dataSource.approvePaymentRequest(requestId));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentRequestModel>> rejectPaymentRequest(
    int requestId, {
    String? sellerNote,
  }) async {
    try {
      return Right(await _dataSource.rejectPaymentRequest(
        requestId,
        sellerNote: sellerNote,
      ));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
