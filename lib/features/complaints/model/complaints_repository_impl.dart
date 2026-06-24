import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'complaint_model.dart';
import 'complaints_repository.dart';
import 'datasources/complaints_remote_datasource.dart';

class ComplaintsRepositoryImpl implements ComplaintsRepository {
  final ComplaintsRemoteDataSource _dataSource;

  const ComplaintsRepositoryImpl(this._dataSource);

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    if (e is ForbiddenException) return ForbiddenFailure(e.message);
    return ServerFailure(e.message);
  }

  @override
  Future<Either<Failure, List<ComplaintModel>>> listMyComplaints() async {
    try {
      return Right(await _dataSource.listMyComplaints());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ComplaintModel>> createComplaint({
    required int paymentRequestId,
    required String title,
    required String description,
    required String complaintType,
  }) async {
    try {
      return Right(
        await _dataSource.createComplaint(
          paymentRequestId: paymentRequestId,
          title: title,
          description: description,
          complaintType: complaintType,
        ),
      );
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ComplaintModel>> getComplaint(int complaintId) async {
    try {
      return Right(await _dataSource.getComplaint(complaintId));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelComplaint(int complaintId) async {
    try {
      await _dataSource.cancelComplaint(complaintId);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ComplaintModel>> reopenComplaint(
      int complaintId) async {
    try {
      return Right(await _dataSource.reopenComplaint(complaintId));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
