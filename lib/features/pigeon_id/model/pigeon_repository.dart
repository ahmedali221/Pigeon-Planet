import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'pigeon_model.dart';

abstract class PigeonRepository {
  Future<Either<Failure, PigeonModel>> saveBird(PigeonModel pigeon);
}
