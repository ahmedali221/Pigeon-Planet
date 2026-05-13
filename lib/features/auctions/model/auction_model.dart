import 'auction_item_model.dart';

class AuctionModel {
  final int id;
  final String title;
  final String description;
  final String auctionType;
  final String auctionTypeDisplay;
  final String status;
  final String statusDisplay;
  final String sellerNickname;
  final DateTime startTime;
  final DateTime endTime;
  final int? timeRemaining;
  final bool isActive;
  final bool isEnded;
  final bool buyNowEnabled;
  final double? buyNowPrice;
  final double minBidIncrement;
  final int itemCount;
  final List<AuctionItemModel> items;

  const AuctionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.auctionType,
    required this.auctionTypeDisplay,
    required this.status,
    this.statusDisplay = '',
    required this.sellerNickname,
    required this.startTime,
    required this.endTime,
    this.timeRemaining,
    required this.isActive,
    required this.isEnded,
    required this.buyNowEnabled,
    this.buyNowPrice,
    required this.minBidIncrement,
    this.itemCount = 0,
    this.items = const [],
  });

  double get currentPrice =>
      items.isNotEmpty ? items.first.currentPrice : 0.0;

  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final endTime = DateTime.parse(json['end_time'] as String);
    final status = json['status'] as String? ?? '';
    final isActive = json['is_active'] as bool? ??
        (status == 'active' && endTime.isAfter(now));
    final isEnded = json['is_ended'] as bool? ??
        (status == 'ended' || endTime.isBefore(now));

    return AuctionModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      auctionType: json['auction_type'] as String? ?? '',
      auctionTypeDisplay: json['auction_type_display'] as String? ?? '',
      status: status,
      statusDisplay: json['status_display'] as String? ?? '',
      sellerNickname: json['seller_nickname'] as String? ?? '',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: endTime,
      timeRemaining: json['time_remaining'] as int?,
      isActive: isActive,
      isEnded: isEnded,
      buyNowEnabled: json['buy_now_enabled'] as bool? ?? false,
      buyNowPrice: json['buy_now_price'] != null
          ? double.tryParse(json['buy_now_price'].toString())
          : null,
      minBidIncrement:
          double.parse((json['min_bid_increment'] ?? '1.00').toString()),
      itemCount: json['item_count'] as int? ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => AuctionItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
