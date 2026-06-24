import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final int id;
  final int senderProfileId;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final int? conversationId;

  const ChatMessageModel({
    required this.id,
    required this.senderProfileId,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
    this.conversationId,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    final senderProfileId =
        sender is Map ? (sender['id'] as int? ?? 0) : (sender as int? ?? 0);
    final readAtRaw = json['read_at'] as String?;
    return ChatMessageModel(
      id: json['id'] as int,
      senderProfileId: senderProfileId,
      body: json['body'] as String? ?? '',
      createdAt: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
      readAt: readAtRaw != null ? DateTime.tryParse(readAtRaw) : null,
      conversationId: json['conversation_id'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, senderProfileId, body, createdAt, isRead, readAt, conversationId];
}
