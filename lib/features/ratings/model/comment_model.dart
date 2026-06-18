import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final int id;
  final String ownerNickname;
  final String text;
  final DateTime created;

  const CommentModel({
    required this.id,
    required this.ownerNickname,
    required this.text,
    required this.created,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['id'] as int,
      ownerNickname: owner?['nickname'] as String? ?? '',
      text: json['text'] as String? ?? '',
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, ownerNickname, text, created];
}
