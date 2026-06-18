class BidModel {
  final int id;
  final int bidder;
  final String bidderUsername;
  final double amount;
  final DateTime created;
  final bool isWinningBid;
  final int? itemId;
  final String? auctionTitle;

  const BidModel({
    required this.id,
    required this.bidder,
    required this.bidderUsername,
    required this.amount,
    required this.created,
    required this.isWinningBid,
    this.itemId,
    this.auctionTitle,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) => BidModel(
        id: json['id'] as int,
        bidder: json['bidder'] as int? ?? 0,
        bidderUsername: json['bidder_username'] as String? ?? '',
        amount: double.parse(json['amount'].toString()),
        created: DateTime.parse(json['created'] as String),
        isWinningBid: json['is_winning_bid'] as bool? ?? false,
        itemId: json['item'] as int?,
        auctionTitle: json['auction_title'] as String?,
      );
}
