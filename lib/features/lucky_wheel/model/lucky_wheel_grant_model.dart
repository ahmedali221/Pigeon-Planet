import 'package:equatable/equatable.dart';

class LuckyWheelGrantModel extends Equatable {
  final int id;
  final String sourceType;
  final String? sourceId;
  final int totalAttempts;
  final int remainingAttempts;
  final String? expiresAt;
  final bool isActive;
  final String created;

  const LuckyWheelGrantModel({
    required this.id,
    required this.sourceType,
    this.sourceId,
    required this.totalAttempts,
    required this.remainingAttempts,
    this.expiresAt,
    required this.isActive,
    required this.created,
  });

  factory LuckyWheelGrantModel.fromJson(Map<String, dynamic> json) {
    return LuckyWheelGrantModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      sourceType: json['source_type'] as String? ?? '',
      sourceId: json['source_id'] as String?,
      totalAttempts: (json['total_attempts'] as num?)?.toInt() ?? 0,
      remainingAttempts: (json['remaining_attempts'] as num?)?.toInt() ?? 0,
      expiresAt: json['expires_at'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      created: json['created'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, sourceType, remainingAttempts];
}
