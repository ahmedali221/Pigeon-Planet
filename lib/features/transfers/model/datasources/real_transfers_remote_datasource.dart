import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../home/model/seller_model.dart';
import '../ownership_transfer_model.dart';
import 'transfers_remote_datasource.dart';

class RealTransfersRemoteDataSource implements TransfersRemoteDataSource {
  final DioClient _dio;

  const RealTransfersRemoteDataSource(this._dio);

  OwnershipTransferModel _parse(dynamic data) =>
      OwnershipTransferModel.fromJson(data as Map<String, dynamic>);

  List<OwnershipTransferModel> _parseList(dynamic data) {
    List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      throw const ServerException('Unexpected response format');
    }
    return items.map(_parse).toList();
  }

  @override
  Future<List<OwnershipTransferModel>> getTransfers({int? assetId}) async {
    final queryParams = assetId != null ? {'asset_id': assetId} : null;
    final response = await _dio.get(
      ApiConstants.transfers,
      queryParameters: queryParams,
    );
    return _parseList(response.data);
  }

  @override
  Future<OwnershipTransferModel> createTransfer({
    required int assetId,
    required int toProfileId,
    String? note,
  }) async {
    final response = await _dio.post(
      ApiConstants.transfers,
      data: {
        'asset_id': assetId,
        'to_profile_id': toProfileId,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return _parse(response.data);
  }

  @override
  Future<List<SellerModel>> searchSellers(String query) async {
    final response = await _dio.get(
      ApiConstants.feedSellersList,
      queryParameters: {'search': query, 'page_size': 20},
    );
    final data = response.data;
    List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      throw const ServerException('Unexpected response format');
    }
    return items
        .map((e) => SellerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
