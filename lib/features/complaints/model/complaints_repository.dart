import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'complaint_model.dart';

abstract class ComplaintsRepository {
  Future<Either<Failure, List<ComplaintModel>>> listMyComplaints();

  Future<Either<Failure, ComplaintModel>> createComplaint({
    required int paymentRequestId,
    required String title,
    required String description,
    required String complaintType,
  });

  Future<Either<Failure, ComplaintModel>> getComplaint(int complaintId);

  Future<Either<Failure, void>> cancelComplaint(int complaintId);
  Future<Either<Failure, ComplaintModel>> reopenComplaint(int complaintId);
}
