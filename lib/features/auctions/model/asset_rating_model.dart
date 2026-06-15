class AssetRatingModel {
  final int id;
  final String ownerType;
  final int stars;
  final String? commentText;
  final DateTime created;

  const AssetRatingModel({
    required this.id,
    required this.ownerType,
    required this.stars,
    this.commentText,
    required this.created,
  });

  factory AssetRatingModel.fromJson(Map<String, dynamic> json) {
    final comment = json['comment'] as Map<String, dynamic>?;
    return AssetRatingModel(
      id: json['id'] as int,
      ownerType: (json['owner'] as Map<String, dynamic>?)?['type'] as String? ?? '',
      stars: json['stars'] as int,
      commentText: comment?['text'] as String?,
      created: DateTime.parse(json['created'] as String),
    );
  }
}
