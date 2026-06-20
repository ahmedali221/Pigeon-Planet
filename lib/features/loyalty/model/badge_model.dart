import 'package:equatable/equatable.dart';

class BadgeModel extends Equatable {
  final int id;
  final String key;
  final String name;
  final String description;
  final String? iconUrl;
  final String awardedAt;

  const BadgeModel({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.awardedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> j) {
    final badge = j['badge'] as Map<String, dynamic>? ?? j;
    return BadgeModel(
      id: (j['id'] as num?)?.toInt() ?? 0,
      key: badge['key'] as String? ?? '',
      name: badge['name'] as String? ?? '',
      description: badge['description'] as String? ?? '',
      iconUrl: badge['icon_url'] as String?,
      awardedAt: j['awarded_at'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, key, name, description, iconUrl, awardedAt];
}
