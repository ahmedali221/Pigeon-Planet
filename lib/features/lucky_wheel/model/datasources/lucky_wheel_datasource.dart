import '../wheel_prize_model.dart';

abstract class LuckyWheelDataSource {
  Future<List<WheelPrizeModel>> fetchPrizes({required bool isSeller});
}
