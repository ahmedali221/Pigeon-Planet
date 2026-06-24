class LuckyWheelSpinHistoryModel {
  final int id;
  final String status;
  final Map<String, dynamic> prizeSnapshot;
  final String? awardedAt;
  final String created;

  LuckyWheelSpinHistoryModel({
    required this.id,
    required this.status,
    required this.prizeSnapshot,
    this.awardedAt,
    required this.created,
  });

  factory LuckyWheelSpinHistoryModel.fromJson(Map<String, dynamic> json) {
    return LuckyWheelSpinHistoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      prizeSnapshot:
          (json['prize_snapshot'] as Map<String, dynamic>?) ?? {},
      awardedAt: json['awarded_at'] as String?,
      created: json['created'] as String? ?? '',
    );
  }

  String get prizeLabel =>
      prizeSnapshot['label'] as String? ?? 'بدون جائزة';

  String get prizeType =>
      prizeSnapshot['prize_type'] as String? ?? 'no_prize';

  bool get wasAwarded => awardedAt != null;

  String get emoji => switch (prizeType) {
        'pp_coins' => '🌕',
        'discount_offer' => '✂️',
        'cashback_offer' => '💰',
        'badge' => '🏅',
        'no_prize' => '🍀',
        _ => '🎁',
      };

  DateTime get createdAt =>
      DateTime.tryParse(created) ?? DateTime.fromMillisecondsSinceEpoch(0);
}
