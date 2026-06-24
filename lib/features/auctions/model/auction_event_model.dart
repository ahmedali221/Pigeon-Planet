class AuctionEventModel {
  final int id;
  final int? auctionId;
  final int? itemId;
  final int? bidId;
  final int? performerId;
  final String? userPhone;
  final String eventType;
  final String eventTypeDisplay;
  final String notes;
  final DateTime? created;

  const AuctionEventModel({
    required this.id,
    this.auctionId,
    this.itemId,
    this.bidId,
    this.performerId,
    this.userPhone,
    required this.eventType,
    required this.eventTypeDisplay,
    required this.notes,
    this.created,
  });

  factory AuctionEventModel.fromJson(Map<String, dynamic> json) =>
      AuctionEventModel(
        id: (json['id'] as num).toInt(),
        auctionId: (json['auction'] as num?)?.toInt(),
        itemId: (json['item'] as num?)?.toInt(),
        bidId: (json['bid'] as num?)?.toInt(),
        performerId: (json['performer'] as num?)?.toInt(),
        userPhone: json['user_phone'] as String?,
        eventType: json['event_type'] as String? ?? '',
        eventTypeDisplay: json['event_type_display'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        created: DateTime.tryParse(json['created'] as String? ?? ''),
      );
}
