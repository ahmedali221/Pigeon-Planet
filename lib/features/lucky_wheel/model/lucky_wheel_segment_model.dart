import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LuckyWheelSegmentModel extends Equatable {
  final int id;
  final String label;
  final String description;
  final String prizeType;
  final int? pointsAmount;
  final String? badgeType;
  final Map<String, dynamic> metadata;

  const LuckyWheelSegmentModel({
    required this.id,
    required this.label,
    required this.description,
    required this.prizeType,
    this.pointsAmount,
    this.badgeType,
    this.metadata = const {},
  });

  factory LuckyWheelSegmentModel.fromJson(Map<String, dynamic> json) {
    return LuckyWheelSegmentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
      prizeType: json['prize_type'] as String? ?? 'no_prize',
      pointsAmount: (json['points_amount'] as num?)?.toInt(),
      badgeType: json['badge_type'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }

  Color get color => switch (prizeType) {
        'pp_coins' => const Color(0xFFF59E0B),
        'discount_offer' => const Color(0xFFEC4899),
        'cashback_offer' => const Color(0xFF14B8A6),
        'badge' => const Color(0xFF8B5CF6),
        'no_prize' => const Color(0xFF22C55E),
        _ => const Color(0xFF6366F1),
      };

  String get emoji => switch (prizeType) {
        'pp_coins' => '🌕',
        'discount_offer' => '✂️',
        'cashback_offer' => '💰',
        'badge' => '🏅',
        'no_prize' => '🍀',
        _ => '🎁',
      };

  @override
  List<Object?> get props => [id, label, prizeType];
}
