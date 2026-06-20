class AuctionCommentModel {
  final int id;
  final String body;
  final bool isAnnouncement;
  final int senderId;
  final String senderNickname;
  final String senderType;
  final bool isMine;
  final DateTime createdAt;

  const AuctionCommentModel({
    required this.id,
    required this.body,
    required this.isAnnouncement,
    required this.senderId,
    required this.senderNickname,
    required this.senderType,
    required this.isMine,
    required this.createdAt,
  });

  factory AuctionCommentModel.fromJson(Map<String, dynamic> json) {
    return AuctionCommentModel(
      id: json['id'] as int,
      body: json['body'] as String? ?? '',
      isAnnouncement: json['is_announcement'] as bool? ?? false,
      senderId: json['sender_id'] as int,
      senderNickname: json['sender_nickname'] as String? ?? '',
      senderType: json['sender_type'] as String? ?? '',
      isMine: json['is_mine'] as bool? ?? false,
      createdAt: DateTime.parse(json['created'] as String),
    );
  }
}
