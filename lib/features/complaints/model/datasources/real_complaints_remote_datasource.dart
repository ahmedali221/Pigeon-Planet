import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../complaint_model.dart';
import 'complaints_remote_datasource.dart';

class RealComplaintsRemoteDataSource implements ComplaintsRemoteDataSource {
  final DioClient _dio;

  const RealComplaintsRemoteDataSource(this._dio);

  @override
  Future<List<ComplaintModel>> listMyComplaints() async {
    try {
      final response = await _dio.get(ApiConstants.myComplaints);
      final data = response.data;
      final list = data is List
          ? data
          : (data is Map ? (data['results'] as List? ?? []) : []);
      return list
          .map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحميل الشكاوى');
    }
  }

  @override
  Future<ComplaintModel> createComplaint({
    required int paymentRequestId,
    required String title,
    required String description,
    required String complaintType,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.complaints,
        data: {
          'payment_request_id': paymentRequestId,
          'title': title,
          'description': description,
          'complaint_type': complaintType,
        },
      );
      return ComplaintModel.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل في تقديم الشكوى');
    }
  }

  @override
  Future<ComplaintModel> getComplaint(int complaintId) async {
    try {
      final response = await _dio.get(
        ApiConstants.complaintDetail(complaintId),
      );
      return ComplaintModel.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحميل تفاصيل الشكوى');
    }
  }

  @override
  Future<void> cancelComplaint(int complaintId) async {
    try {
      await _dio.post(ApiConstants.cancelComplaint(complaintId));
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل في إلغاء الشكوى');
    }
  }
}
