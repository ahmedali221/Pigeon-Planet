import 'package:equatable/equatable.dart';

abstract class ComplaintsEvent extends Equatable {
  const ComplaintsEvent();

  @override
  List<Object?> get props => [];
}

class ComplaintsLoadRequested extends ComplaintsEvent {
  const ComplaintsLoadRequested();
}

class ComplaintDetailRequested extends ComplaintsEvent {
  final int complaintId;

  const ComplaintDetailRequested(this.complaintId);

  @override
  List<Object?> get props => [complaintId];
}

class ComplaintCreateRequested extends ComplaintsEvent {
  final int paymentRequestId;
  final String title;
  final String description;
  final String complaintType;

  const ComplaintCreateRequested({
    required this.paymentRequestId,
    required this.title,
    required this.description,
    required this.complaintType,
  });

  @override
  List<Object?> get props => [
    paymentRequestId,
    title,
    description,
    complaintType,
  ];
}

class ComplaintCancelRequested extends ComplaintsEvent {
  final int complaintId;

  const ComplaintCancelRequested(this.complaintId);

  @override
  List<Object?> get props => [complaintId];
}

class ComplaintReopenRequested extends ComplaintsEvent {
  final int complaintId;

  const ComplaintReopenRequested(this.complaintId);

  @override
  List<Object?> get props => [complaintId];
}
