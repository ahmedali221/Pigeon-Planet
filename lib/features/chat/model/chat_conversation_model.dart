import 'package:equatable/equatable.dart';

class ChatConversationModel extends Equatable {
  final int id;
  final int customerId;
  final String customerNickname;
  final int sellerId;
  final String sellerNickname;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isActive;

  const ChatConversationModel({
    required this.id,
    required this.customerId,
    required this.customerNickname,
    required this.sellerId,
    required this.sellerNickname,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isActive = true,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>? ?? {};
    final seller = json['seller'] as Map<String, dynamic>? ?? {};
    return ChatConversationModel(
      id: json['id'] as int,
      customerId: customer['id'] as int? ?? 0,
      customerNickname:
          customer['nickname'] as String? ?? customer['username'] as String? ?? '',
      sellerId: seller['id'] as int? ?? 0,
      sellerNickname:
          seller['nickname'] as String? ?? seller['username'] as String? ?? '',
      lastMessage: (json['last_message'] as Map<String, dynamic>?)?['body'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  ChatConversationModel copyWith({int? unreadCount, bool? isActive}) {
    return ChatConversationModel(
      id: id,
      customerId: customerId,
      customerNickname: customerNickname,
      sellerId: sellerId,
      sellerNickname: sellerNickname,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerNickname,
        sellerId,
        sellerNickname,
        lastMessage,
        lastMessageAt,
        unreadCount,
        isActive,
      ];
}
