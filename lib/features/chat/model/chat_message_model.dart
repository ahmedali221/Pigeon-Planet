import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final int id;
  final int senderProfileId;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessageModel({
    required this.id,
    required this.senderProfileId,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    final senderProfileId =
        sender is Map ? (sender['id'] as int? ?? 0) : (sender as int? ?? 0);
    return ChatMessageModel(
      id: json['id'] as int,
      senderProfileId: senderProfileId,
      body: json['body'] as String? ?? '',
      createdAt: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, senderProfileId, body, createdAt, isRead];
}
