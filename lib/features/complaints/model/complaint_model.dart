import 'package:equatable/equatable.dart';

class ComplaintModel extends Equatable {
  final int id;
  final int paymentRequestId;
  final String title;
  final String complaintType; // 'post_sale' | 'payment_rejected' | 'other'
  final String status; // 'open' | 'in_review' | 'resolved' | 'rejected' | 'cancelled'
  final String? description;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? cancelledAt;

  const ComplaintModel({
    required this.id,
    required this.paymentRequestId,
    required this.title,
    required this.complaintType,
    required this.status,
    this.description,
    this.adminNote,
    required this.createdAt,
    this.resolvedAt,
    this.cancelledAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    // List/detail serializer returns payment_request_id as a flat int.
    // Fall back to nested or bare int for any variance.
    int paymentRequestId = json['payment_request_id'] as int? ?? 0;
    if (paymentRequestId == 0) {
      final pr = json['payment_request'];
      if (pr is int) {
        paymentRequestId = pr;
      } else if (pr is Map) {
        paymentRequestId = pr['id'] as int? ?? 0;
      }
    }

    return ComplaintModel(
      id: json['id'] as int,
      paymentRequestId: paymentRequestId,
      title: json['title'] as String? ?? 'شكوى #${json['id']}',
      complaintType: json['complaint_type'] as String? ?? 'post_sale',
      status: json['status'] as String? ?? 'open',
      description: json['description'] as String?,
      adminNote: (json['admin_note'] as String?)?.isEmpty == true
          ? null
          : json['admin_note'] as String?,
      createdAt: (json['created'] ?? json['created_at']) != null
          ? DateTime.parse((json['created'] ?? json['created_at']) as String)
          : DateTime.now(),
      resolvedAt: DateTime.tryParse(json['resolved_at'] as String? ?? ''),
      cancelledAt: DateTime.tryParse(json['cancelled_at'] as String? ?? ''),
    );
  }

  ComplaintModel copyWith({String? status}) => ComplaintModel(
        id: id,
        paymentRequestId: paymentRequestId,
        title: title,
        complaintType: complaintType,
        status: status ?? this.status,
        description: description,
        adminNote: adminNote,
        createdAt: createdAt,
        resolvedAt: resolvedAt,
        cancelledAt: cancelledAt,
      );

  bool get isOpen => status == 'open';

  String get statusLabel => switch (status) {
        'open' => 'مفتوحة',
        'in_review' => 'قيد المراجعة',
        'resolved' => 'محلولة',
        'rejected' => 'مرفوضة',
        'cancelled' => 'ملغاة',
        _ => status,
      };

  String get typeLabel => switch (complaintType) {
        'post_sale' => 'ما بعد البيع',
        'payment_rejected' => 'دفع مرفوض',
        'other' => 'أخرى',
        _ => complaintType,
      };

  @override
  List<Object?> get props => [
        id,
        paymentRequestId,
        title,
        complaintType,
        status,
        description,
        adminNote,
        createdAt,
        resolvedAt,
        cancelledAt,
      ];
}
