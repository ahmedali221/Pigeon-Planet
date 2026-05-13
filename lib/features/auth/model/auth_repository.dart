import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login({
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, UserModel>> registerPersonal({
    required String phoneNumber,
    required String password,
    required String country,
  });

  Future<Either<Failure, UserModel>> registerProvider({
    required String phoneNumber,
    required String password,
    required String country,
  });

  Future<Either<Failure, String>> verifyOtp({
    required String phoneNumber,
    required String code,
  });

  Future<Either<Failure, void>> resendOtp({required String phoneNumber});

  Future<Either<Failure, UserModel>> switchProfile(String newProfile);

  Future<Either<Failure, UserModel?>> getStoredUser();
}
