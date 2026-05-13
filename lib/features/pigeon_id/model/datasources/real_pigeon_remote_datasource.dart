import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../pigeon_model.dart';
import 'pigeon_remote_datasource.dart';

class RealPigeonRemoteDataSource implements PigeonRemoteDataSource {
  final DioClient _dio;

  const RealPigeonRemoteDataSource(this._dio);

  @override
  Future<PigeonModel> saveBird(PigeonModel pigeon) async {
    final body = {
      'name': pigeon.ringNumber,
      'ring_number': pigeon.ringNumber,
      'title': pigeon.ringNumber,
      'gender': pigeon.gender == PigeonGender.female ? 'female' : 'male',
      'colour': pigeon.breed,
      if (pigeon.hatchDate != null)
        'birthday': pigeon.hatchDate!.toIso8601String().split('T').first,
      'is_for_auction': false,
    };

    final response = await _dio.post(ApiConstants.birds, data: body);
    return PigeonModel.fromJson(response.data as Map<String, dynamic>);
  }
}
