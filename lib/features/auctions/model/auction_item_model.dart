import 'bid_model.dart';
import 'bird_summary_model.dart';

class AuctionItemModel {
  final int id;
  final int auctionId;
  final String auctionTitle;
  final String status;
  final double startingPrice;
  final double currentPrice;
  final String? currentHighestBidder;
  final bool isActive;
  final BirdSummaryModel bird;
  final List<BidModel> bids;

  const AuctionItemModel({
    required this.id,
    required this.auctionId,
    required this.auctionTitle,
    required this.status,
    required this.startingPrice,
    required this.currentPrice,
    this.currentHighestBidder,
    required this.isActive,
    required this.bird,
    this.bids = const [],
  });

  factory AuctionItemModel.fromJson(Map<String, dynamic> json) =>
      AuctionItemModel(
        id: json['id'] as int,
        auctionId: json['auction_id'] as int? ?? 0,
        auctionTitle: json['auction_title'] as String? ?? '',
        status: json['status'] as String? ?? '',
        startingPrice: double.parse(json['starting_price'].toString()),
        currentPrice: double.parse(json['current_price'].toString()),
        currentHighestBidder: json['current_highest_bidder'] as String?,
        isActive: json['is_active'] as bool? ?? false,
        bird: BirdSummaryModel.fromJson(
            json['bird'] as Map<String, dynamic>? ?? {}),
        bids: (json['bids'] as List<dynamic>? ?? [])
            .map((b) => BidModel.fromJson(b as Map<String, dynamic>))
            .toList(),
      );
}
