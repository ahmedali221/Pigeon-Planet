import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'datasources/referrals_remote_datasource.dart';
import 'referral_model.dart';
import 'referrals_repository.dart';

class ReferralsRepositoryImpl implements ReferralsRepository {
  final ReferralsRemoteDataSource _dataSource;

  const ReferralsRepositoryImpl(this._dataSource);

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    if (e is ForbiddenException) return ForbiddenFailure(e.message);
    return ServerFailure(e.message);
  }

  @override
  Future<Either<Failure, ReferralCodeModel>> createOrGetCode() async {
    try {
      return Right(await _dataSource.createOrGetCode());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> redeemCode(String code) async {
    try {
      await _dataSource.redeemCode(code);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
