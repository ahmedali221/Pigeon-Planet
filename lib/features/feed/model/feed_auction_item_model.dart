class FeedAuctionItemModel {
  final int id;
  final String title;
  final String source; // 'following' | 'discovery'
  final double currentPrice;
  final String sellerNickname;
  final int? sellerId;
  final String? thumbnailUrl;
  final int? timeRemaining; // seconds until end
  final String status;

  const FeedAuctionItemModel({
    required this.id,
    required this.title,
    required this.source,
    required this.currentPrice,
    required this.sellerNickname,
    this.sellerId,
    this.thumbnailUrl,
    this.timeRemaining,
    this.status = 'active',
  });

  factory FeedAuctionItemModel.fromJson(Map<String, dynamic> json) {
    // Backend wraps auction data under 'item'; source is at top level.
    final item = json['item'] as Map<String, dynamic>? ?? json;

    return FeedAuctionItemModel(
      id: item['id'] as int? ?? 0,
      title: item['title'] as String? ?? '',
      source: json['source'] as String? ?? 'discovery',
      currentPrice: double.tryParse(item['current_price']?.toString() ?? '') ?? 0.0,
      sellerNickname: item['seller_nickname'] as String? ?? '',
      sellerId: null,
      thumbnailUrl: item['thumbnail_url'] as String?,
      timeRemaining: item['time_remaining'] as int?,
      status: item['status'] as String? ?? 'active',
    );
  }
}

class FeedAuctionResult {
  final List<FeedAuctionItemModel> items;
  final String? nextCursor;

  const FeedAuctionResult({required this.items, this.nextCursor});
}
