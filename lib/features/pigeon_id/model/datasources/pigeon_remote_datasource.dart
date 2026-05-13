import '../pigeon_model.dart';

abstract class PigeonRemoteDataSource {
  Future<PigeonModel> saveBird(PigeonModel pigeon);
}
