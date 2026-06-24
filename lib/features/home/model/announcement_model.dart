class AnnouncementModel {
  final int id;
  final String title;
  final String subtitle;
  final String details;
  final String imageUrl;
  final String target;
  final bool isActive;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.imageUrl,
    required this.target,
    required this.isActive,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      imageUrl:
          json['image_url']?.toString() ?? json['image']?.toString() ?? '',
      target: json['target']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
