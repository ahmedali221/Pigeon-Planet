class SellerBlockModel {
  final int id;
  final int profileId;
  final String profileNickname;
  final bool isActive;
  final DateTime? created;

  const SellerBlockModel({
    required this.id,
    required this.profileId,
    required this.profileNickname,
    required this.isActive,
    this.created,
  });

  factory SellerBlockModel.fromJson(Map<String, dynamic> json) {
    // Backend returns 'other_participant' — the blocked/blocking counterpart
    // relative to the active profile. Falls back to 'seller' if missing.
    final other = json['other_participant'] as Map<String, dynamic>? ??
        json['seller'] as Map<String, dynamic>? ??
        {};
    return SellerBlockModel(
      id: json['id'] as int? ?? 0,
      profileId: other['id'] as int? ?? 0,
      profileNickname: other['nickname'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      created: DateTime.tryParse(json['created'] as String? ?? ''),
    );
  }
}
