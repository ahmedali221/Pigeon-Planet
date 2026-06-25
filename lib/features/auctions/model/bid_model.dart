class BidModel {
  final int id;
  final int? bidder;
  final String? bidderUsername;
  final String? bidderPhone;
  final double amount;
  final DateTime created;
  final bool isWinningBid;
  final int? itemId;
  final String? auctionTitle;

  const BidModel({
    required this.id,
    this.bidder,
    this.bidderUsername,
    this.bidderPhone,
    required this.amount,
    required this.created,
    required this.isWinningBid,
    this.itemId,
    this.auctionTitle,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) => BidModel(
        id: json['id'] as int,
        bidder: json['bidder'] as int?,
        bidderUsername: json['bidder_username'] as String?,
        bidderPhone: json['bidder_phone'] as String?,
        amount: double.parse(json['amount'].toString()),
        created: DateTime.parse(json['created'] as String),
        isWinningBid: json['is_winning_bid'] as bool? ?? false,
        itemId: json['item'] as int?,
        auctionTitle: json['auction_title'] as String?,
      );
}
