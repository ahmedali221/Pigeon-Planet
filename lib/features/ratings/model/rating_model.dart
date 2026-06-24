import 'package:equatable/equatable.dart';

class RatingModel extends Equatable {
  final int id;
  final int ownerId;
  final String ownerType;
  final String ownerNickname;
  final int? assetId;
  final String? assetTitle;
  final String? assetCategory;
  final int? sellerId;
  final String? sellerNickname;
  final int stars;
  final String? commentText;
  final DateTime created;
  final DateTime? modified;

  const RatingModel({
    required this.id,
    required this.ownerId,
    required this.ownerType,
    required this.ownerNickname,
    this.assetId,
    this.assetTitle,
    this.assetCategory,
    this.sellerId,
    this.sellerNickname,
    required this.stars,
    this.commentText,
    required this.created,
    this.modified,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    final asset = json['asset'] as Map<String, dynamic>?;
    final seller = json['seller'] as Map<String, dynamic>?;
    final comment = json['comment'] as Map<String, dynamic>?;
    return RatingModel(
      id: json['id'] as int,
      ownerId: (owner?['id'] as num?)?.toInt() ?? 0,
      ownerType: owner?['type'] as String? ?? '',
      ownerNickname: owner?['nickname'] as String? ??
          owner?['type'] as String? ??
          '',
      assetId: (asset?['id'] as num?)?.toInt(),
      assetTitle: asset?['title'] as String?,
      assetCategory: asset?['category'] as String?,
      sellerId: (seller?['id'] as num?)?.toInt(),
      sellerNickname: seller?['nickname'] as String?,
      stars: json['stars'] as int,
      commentText: comment?['text'] as String?,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      modified: DateTime.tryParse(json['modified'] as String? ?? ''),
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        ownerType,
        ownerNickname,
        assetId,
        assetTitle,
        assetCategory,
        sellerId,
        sellerNickname,
        stars,
        commentText,
        created,
        modified,
      ];
}
