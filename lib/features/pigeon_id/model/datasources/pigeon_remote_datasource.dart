import '../pigeon_model.dart';

abstract class PigeonRemoteDataSource {
  Future<PigeonModel> saveBird(PigeonModel pigeon);
  Future<PigeonModel> updateBird(int id, PigeonModel pigeon);
  Future<void> deleteBird(int id);
}
