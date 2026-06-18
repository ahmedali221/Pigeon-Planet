import 'package:equatable/equatable.dart';

class RatingModel extends Equatable {
  final int id;
  final String ownerNickname;
  final int stars;
  final String? commentText;
  final DateTime created;

  const RatingModel({
    required this.id,
    required this.ownerNickname,
    required this.stars,
    this.commentText,
    required this.created,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    final comment = json['comment'] as Map<String, dynamic>?;
    return RatingModel(
      id: json['id'] as int,
      ownerNickname: owner?['nickname'] as String? ?? '',
      stars: json['stars'] as int,
      commentText: comment?['text'] as String?,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, ownerNickname, stars, commentText, created];
}
