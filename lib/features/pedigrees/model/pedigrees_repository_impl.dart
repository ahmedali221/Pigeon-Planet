import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'datasources/pedigrees_remote_datasource.dart';
import 'pedigree_document_model.dart';
import 'pedigrees_repository.dart';

class PedigreesRepositoryImpl implements PedigreesRepository {
  final PedigreesRemoteDataSource _dataSource;

  const PedigreesRepositoryImpl(this._dataSource);

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    if (e is ForbiddenException) return ForbiddenFailure(e.message);
    return ServerFailure(e.message);
  }

  @override
  Future<Either<Failure, List<PedigreeDocumentModel>>> listDocuments({int? birdId}) async {
    try {
      return Right(await _dataSource.listDocuments(birdId: birdId));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PedigreeDocumentModel>> uploadDocument(
    XFile file, {
    int? birdId,
  }) async {
    try {
      return Right(await _dataSource.uploadDocument(file, birdId: birdId));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PedigreeDocumentModel>> createTextDocument(
    String ringNumber, {
    String description = '',
    int? birdId,
  }) async {
    try {
      return Right(await _dataSource.createTextDocument(
        ringNumber,
        description: description,
        birdId: birdId,
      ));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PedigreeDocumentModel>> getDocument(int id) async {
    try {
      return Right(await _dataSource.getDocument(id));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PedigreeDocumentModel>> reviewDocument(
    int id, {
    required String ringNumber,
    required String description,
  }) async {
    try {
      return Right(await _dataSource.reviewDocument(
        id,
        ringNumber: ringNumber,
        description: description,
      ));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
