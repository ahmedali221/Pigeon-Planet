import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../promotions/model/user_promotion_grant_model.dart';

class WheelSpinResultModel extends Equatable {
  final int spinId;
  final int remainingAttempts;
  final Map<String, dynamic> prize;
  final bool awarded;
  final Map<String, dynamic> balances;
  final UserPromotionGrantModel? userPromotionGrant;

  // Winner index within the segments list — resolved by the bloc after spin.
  final int winnerIndex;

  const WheelSpinResultModel({
    required this.spinId,
    required this.remainingAttempts,
    required this.prize,
    required this.awarded,
    required this.balances,
    this.userPromotionGrant,
    required this.winnerIndex,
  });

  factory WheelSpinResultModel.fromJson(
    Map<String, dynamic> json, {
    required int winnerIndex,
  }) {
    final promoJson = json['user_promotion_grant'];
    return WheelSpinResultModel(
      spinId: (json['spin_id'] as num?)?.toInt() ?? 0,
      remainingAttempts: (json['remaining_attempts'] as num?)?.toInt() ?? 0,
      prize: (json['prize'] as Map<String, dynamic>?) ?? const {},
      awarded: json['awarded'] as bool? ?? false,
      balances: (json['balances'] as Map<String, dynamic>?) ?? const {},
      userPromotionGrant: promoJson != null
          ? UserPromotionGrantModel.fromJson(
              promoJson as Map<String, dynamic>)
          : null,
      winnerIndex: winnerIndex,
    );
  }

  // ── Display helpers derived from the prize snapshot ───────────────────────

  int get prizeId => (prize['id'] as num?)?.toInt() ?? 0;
  String get prizeType => prize['prize_type'] as String? ?? 'no_prize';
  String get prizeLabel => prize['label'] as String? ?? '';
  String get prizeDescription => prize['description'] as String? ?? '';

  bool get isNoPrize => prizeType == 'no_prize';

  Color get prizeColor => switch (prizeType) {
        'pp_coins' => const Color(0xFFF59E0B),
        'discount_offer' => const Color(0xFFEC4899),
        'cashback_offer' => const Color(0xFF14B8A6),
        'badge' => const Color(0xFF8B5CF6),
        'no_prize' => const Color(0xFF22C55E),
        _ => const Color(0xFF6366F1),
      };

  String get prizeEmoji => switch (prizeType) {
        'pp_coins' => '🌕',
        'discount_offer' => '✂️',
        'cashback_offer' => '💰',
        'badge' => '🏅',
        'no_prize' => '🍀',
        _ => '🎁',
      };

  int? get newPointBalance {
    final v = balances['points'];
    if (v is num) return v.toInt();
    return null;
  }

  @override
  List<Object?> get props => [spinId, prizeType, awarded, winnerIndex];
}
