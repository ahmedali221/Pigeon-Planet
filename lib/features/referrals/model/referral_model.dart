import 'package:equatable/equatable.dart';

class ReferralCodeModel extends Equatable {
  final String code;
  final int ownerProfileId;
  final String? shareUrl;
  final DateTime? expiresAt;
  final bool isUsed;
  final DateTime createdAt;

  const ReferralCodeModel({
    required this.code,
    required this.ownerProfileId,
    this.shareUrl,
    this.expiresAt,
    required this.isUsed,
    required this.createdAt,
  });

  factory ReferralCodeModel.fromJson(Map<String, dynamic> json) =>
      ReferralCodeModel(
        code: json['code'] as String? ?? '',
        ownerProfileId: json['owner_profile_id'] as int? ?? 0,
        shareUrl: json['share_url'] as String?,
        expiresAt: json['expires_at'] != null
            ? DateTime.tryParse(json['expires_at'] as String)
            : null,
        isUsed: json['is_used'] as bool? ?? false,
        createdAt: json['created'] != null
            ? DateTime.tryParse(json['created'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  @override
  List<Object?> get props => [code, ownerProfileId, shareUrl, expiresAt, isUsed, createdAt];
}
