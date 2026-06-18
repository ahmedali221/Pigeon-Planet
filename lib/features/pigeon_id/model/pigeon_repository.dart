import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'pigeon_model.dart';

abstract class PigeonRepository {
  Future<Either<Failure, PigeonModel>> saveBird(PigeonModel pigeon);
  Future<Either<Failure, PigeonModel>> updateBird(int id, PigeonModel pigeon);
  Future<Either<Failure, void>> deleteBird(int id);
  Future<Either<Failure, PigeonModel>> fetchPublicBird(String publicId);
}
