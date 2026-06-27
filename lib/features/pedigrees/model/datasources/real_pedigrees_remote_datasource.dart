import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../pedigree_document_model.dart';
import 'pedigrees_remote_datasource.dart';

class RealPedigreesRemoteDataSource implements PedigreesRemoteDataSource {
  final DioClient _dio;

  const RealPedigreesRemoteDataSource(this._dio);

  @override
  Future<List<PedigreeDocumentModel>> listDocuments({int? birdId}) async {
    final response = await _dio.dio.get(
      ApiConstants.pedigreeDocuments,
      queryParameters: birdId != null ? {'bird_id': birdId} : null,
    );
    final data = response.data;
    final list = (data is Map ? data['results'] : data) as List<dynamic>;
    return list
        .map((e) => PedigreeDocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PedigreeDocumentModel> uploadDocument(XFile file,
      {int? birdId}) async {
    final formData = FormData.fromMap({
      'original_file': await MultipartFile.fromFile(file.path, filename: file.name),
      if (birdId != null) 'bird_id': birdId,
    });
    final response = await _dio.dio.post(
      ApiConstants.pedigreeDocuments,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return PedigreeDocumentModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<PedigreeDocumentModel> createTextDocument(
    String ringNumber, {
    String description = '',
    int? birdId,
  }) async {
    final response = await _dio.dio.post(
      ApiConstants.pedigreeDocuments,
      data: {
        'bird_ring_number': ringNumber,
        'description': description,
        'bird_id': birdId,
      },
    );
    return PedigreeDocumentModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<PedigreeDocumentModel> getDocument(int id) async {
    final response =
        await _dio.dio.get(ApiConstants.pedigreeDocumentDetail(id));
    return PedigreeDocumentModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<PedigreeDocumentModel> reviewDocument(
    int id, {
    required String ringNumber,
    required String description,
  }) async {
    final response = await _dio.dio.patch(
      ApiConstants.pedigreeDocumentReview(id),
      data: {
        'bird_ring_number': ringNumber,
        'description': description,
      },
    );
    return PedigreeDocumentModel.fromJson(
        response.data as Map<String, dynamic>);
  }
}
