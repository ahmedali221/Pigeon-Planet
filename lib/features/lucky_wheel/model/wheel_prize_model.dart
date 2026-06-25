import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WheelPrizeModel extends Equatable {
  final String type;
  final String label;
  final String emoji;
  final Color color;
  final int weight;
  final bool isEnabled;
  final String description;
  final bool showIcon;

  const WheelPrizeModel({
    required this.type,
    required this.label,
    required this.emoji,
    required this.color,
    required this.weight,
    required this.isEnabled,
    required this.description,
    this.showIcon = true,
  });

  factory WheelPrizeModel.fromJson(Map<String, dynamic> json) {
    final hexColor = (json['color'] as String? ?? 'FF6366F1')
        .replaceFirst('#', '')
        .padLeft(8, 'F');
    return WheelPrizeModel(
      type: json['prize_type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🎁',
      color: Color(int.parse(hexColor, radix: 16)),
      weight: json['weight'] as int? ?? 10,
      isEnabled: json['is_enabled'] as bool? ?? true,
      description: json['description'] as String? ?? '',
      showIcon: json['show_icon'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props =>
      [type, label, emoji, weight, isEnabled, description, showIcon];
}
