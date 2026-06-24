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
    required String username,
    String? avatarPath,
  });

  Future<Either<Failure, UserModel>> registerProvider({
    required String phoneNumber,
    required String password,
    required String country,
    required String username,
    String? avatarPath,
  });

  Future<Either<Failure, UserModel>> switchProfile(String newProfile);

  Future<Either<Failure, void>> createSellerProfile();

  Future<Either<Failure, UserModel?>> getStoredUser();

  Future<void> logout();
}
