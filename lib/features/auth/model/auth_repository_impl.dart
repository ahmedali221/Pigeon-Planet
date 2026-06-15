import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'auth_repository.dart';
import 'datasources/auth_remote_datasource.dart';
import 'user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserModel>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      return Right(user);
    } on ApiException catch (e) {
      return Left(_mapApiException(e));
    } on DemoException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e, st) {
      dev.log('login error', error: e, stackTrace: st, name: 'AuthRepo');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> registerPersonal({
    required String phoneNumber,
    required String password,
    required String country,
    required String username,
    String? avatarPath,
  }) async {
    try {
      final user = await remoteDataSource.registerPersonal(
        phoneNumber: phoneNumber,
        password: password,
        country: country,
        username: username,
        avatarPath: avatarPath,
      );
      return Right(user);
    } on ApiException catch (e) {
      return Left(_mapApiException(e));
    } on DemoException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      dev.log('registerPersonal error', error: e, stackTrace: st, name: 'AuthRepo');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> registerProvider({
    required String phoneNumber,
    required String password,
    required String country,
    required String username,
    String? avatarPath,
  }) async {
    try {
      final user = await remoteDataSource.registerProvider(
        phoneNumber: phoneNumber,
        password: password,
        country: country,
        username: username,
        avatarPath: avatarPath,
      );
      return Right(user);
    } on ApiException catch (e) {
      return Left(_mapApiException(e));
    } on DemoException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      dev.log('registerProvider error', error: e, stackTrace: st, name: 'AuthRepo');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    // OTP not yet implemented on backend — mock accepts any 6-digit code
    await Future.delayed(const Duration(milliseconds: 800));
    if (code.length == 6) return const Right('verified');
    return const Left(ValidationFailure('رمز التحقق غير صحيح'));
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String phoneNumber}) async {
    try {
      await remoteDataSource.resendOtp(phoneNumber: phoneNumber);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> switchProfile(String newProfile) async {
    try {
      final user = await remoteDataSource.switchProfile(newProfile);
      return Right(user);
    } on ApiException catch (e) {
      return Left(_mapApiException(e));
    } catch (e, st) {
      dev.log('switchProfile error', error: e, stackTrace: st, name: 'AuthRepo');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createSellerProfile() async {
    try {
      await remoteDataSource.createSellerProfile();
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_mapApiException(e));
    } catch (e, st) {
      dev.log('createSellerProfile error', error: e, stackTrace: st, name: 'AuthRepo');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getStoredUser() async {
    try {
      final user = await remoteDataSource.getStoredUser();
      return Right(user);
    } catch (_) {
      return const Right(null);
    }
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  Failure _mapApiException(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ForbiddenException) return ForbiddenFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    return ServerFailure(e.message);
  }
}
