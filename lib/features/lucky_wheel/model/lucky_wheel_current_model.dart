import 'package:equatable/equatable.dart';

import '../../promotions/model/user_promotion_grant_model.dart';
import 'lucky_wheel_grant_model.dart';
import 'lucky_wheel_segment_model.dart';

class LuckyWheelCurrentModel extends Equatable {
  final bool eligible;
  final int remainingAttempts;
  final String? cooldownUntil;
  final List<LuckyWheelSegmentModel> segments;
  final List<LuckyWheelGrantModel> activeGrants;
  final List<UserPromotionGrantModel> userPromotionGrants;

  const LuckyWheelCurrentModel({
    required this.eligible,
    required this.remainingAttempts,
    this.cooldownUntil,
    required this.segments,
    required this.activeGrants,
    required this.userPromotionGrants,
  });

  LuckyWheelCurrentModel copyWith({int? remainingAttempts}) =>
      LuckyWheelCurrentModel(
        eligible: remainingAttempts != null ? remainingAttempts > 0 : eligible,
        remainingAttempts: remainingAttempts ?? this.remainingAttempts,
        cooldownUntil: cooldownUntil,
        segments: segments,
        activeGrants: activeGrants,
        userPromotionGrants: userPromotionGrants,
      );

  factory LuckyWheelCurrentModel.fromJson(Map<String, dynamic> json) {
    final segList = json['segments'] as List<dynamic>? ?? [];
    final grantList = json['active_grants'] as List<dynamic>? ?? [];
    final promoList = json['user_promotion_grants'] as List<dynamic>? ?? [];

    return LuckyWheelCurrentModel(
      eligible: json['eligible'] as bool? ?? false,
      remainingAttempts: (json['remaining_attempts'] as num?)?.toInt() ?? 0,
      cooldownUntil: json['cooldown_until'] as String?,
      segments: segList
          .map((e) =>
              LuckyWheelSegmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeGrants: grantList
          .map((e) =>
              LuckyWheelGrantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      userPromotionGrants: promoList
          .map((e) =>
              UserPromotionGrantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props =>
      [eligible, remainingAttempts, segments, activeGrants, userPromotionGrants];
}
