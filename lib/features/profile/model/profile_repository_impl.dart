import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'datasources/profile_remote_datasource.dart';
import 'profile_model.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;
  const ProfileRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ProfileModel>> getProfile(String profileType) =>
      _wrap(() => _dataSource.getProfile(profileType));

  @override
  Future<Either<Failure, List<ProfileModel>>> fetchAllSellerProfiles() =>
      _wrap(() => _dataSource.fetchAllSellerProfiles());

  @override
  Future<Either<Failure, void>> createRoom({
    required String nickname,
    required String country,
    required String currency,
  }) =>
      _wrapVoid(() => _dataSource.createRoom(
            nickname: nickname,
            country: country,
            currency: currency,
          ));

  @override
  Future<Either<Failure, ProfileModel>> updateProfile(ProfileModel profile) =>
      _wrap(() => _dataSource.updateProfile(profile));

  @override
  Future<Either<Failure, void>> deleteProfile(ProfileModel profile) =>
      _wrapVoid(() => _dataSource.deleteProfile(profile));

  @override
  Future<Either<Failure, ProfileModel>> uploadProfilePhoto({
    required int profileId,
    required String profileType,
    required String filePath,
  }) =>
      _wrap(() => _dataSource.uploadProfilePhoto(
            profileId: profileId,
            profileType: profileType,
            filePath: filePath,
          ));

  Future<Either<Failure, T>> _wrap<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> _wrapVoid(
      Future<void> Function() fn) async {
    try {
      await fn();
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    return ServerFailure(e.message);
  }
}
