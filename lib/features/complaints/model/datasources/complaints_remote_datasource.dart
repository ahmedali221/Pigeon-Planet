import '../complaint_model.dart';

abstract class ComplaintsRemoteDataSource {
  Future<List<ComplaintModel>> listMyComplaints();
  Future<ComplaintModel> createComplaint({
    required int paymentRequestId,
    required String title,
    required String description,
    required String complaintType,
  });
  Future<ComplaintModel> getComplaint(int complaintId);
  Future<void> cancelComplaint(int complaintId);
}
