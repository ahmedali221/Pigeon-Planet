import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WheelSpinResultModel extends Equatable {
  final String prizeType;
  final String prizeLabel;
  final String prizeEmoji;
  final Color prizeColor;
  final String description;
  final int winnerIndex;

  const WheelSpinResultModel({
    required this.prizeType,
    required this.prizeLabel,
    required this.prizeEmoji,
    required this.prizeColor,
    required this.description,
    required this.winnerIndex,
  });

  @override
  List<Object?> get props => [prizeType, prizeLabel, prizeEmoji, winnerIndex];
}
