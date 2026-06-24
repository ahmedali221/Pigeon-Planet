class AuctionSummaryInsights {
  final int activeCount;
  final int closedCount;
  final int endingSoonCount;
  final int totalBidsReceived;
  final int uniqueBiddersCount;
  final int soldItemsCount;
  final int pendingPaymentCount;

  const AuctionSummaryInsights({
    required this.activeCount,
    required this.closedCount,
    required this.endingSoonCount,
    required this.totalBidsReceived,
    required this.uniqueBiddersCount,
    required this.soldItemsCount,
    required this.pendingPaymentCount,
  });

  factory AuctionSummaryInsights.fromJson(Map<String, dynamic> json) =>
      AuctionSummaryInsights(
        activeCount: (json['active_count'] as num?)?.toInt() ?? 0,
        closedCount: (json['closed_count'] as num?)?.toInt() ?? 0,
        endingSoonCount: (json['ending_soon_count'] as num?)?.toInt() ?? 0,
        totalBidsReceived: (json['total_bids_received'] as num?)?.toInt() ?? 0,
        uniqueBiddersCount:
            (json['unique_bidders_count'] as num?)?.toInt() ?? 0,
        soldItemsCount: (json['sold_items_count'] as num?)?.toInt() ?? 0,
        pendingPaymentCount:
            (json['pending_payment_requests_count'] as num?)?.toInt() ?? 0,
      );
}

class MarketSummaryInsights {
  final int activeListingsCount;
  final int soldItemsCount;
  final int pendingOrderItemsCount;
  final int pendingPaymentCount;
  final int lowStockProductsCount;

  const MarketSummaryInsights({
    required this.activeListingsCount,
    required this.soldItemsCount,
    required this.pendingOrderItemsCount,
    required this.pendingPaymentCount,
    required this.lowStockProductsCount,
  });

  factory MarketSummaryInsights.fromJson(Map<String, dynamic> json) =>
      MarketSummaryInsights(
        activeListingsCount:
            (json['active_listings_count'] as num?)?.toInt() ?? 0,
        soldItemsCount: (json['sold_items_count'] as num?)?.toInt() ?? 0,
        pendingOrderItemsCount:
            (json['pending_order_items_count'] as num?)?.toInt() ?? 0,
        pendingPaymentCount:
            (json['pending_payment_requests_count'] as num?)?.toInt() ?? 0,
        lowStockProductsCount:
            (json['low_stock_products_count'] as num?)?.toInt() ?? 0,
      );
}

class EngagementSummaryInsights {
  final int followersCount;
  final int newFollowers7d;
  final int unreadMessages;
  final int activeConversationsCount;
  final int profileViews7d;
  final int auctionViews7d;
  final int marketItemViews7d;

  const EngagementSummaryInsights({
    required this.followersCount,
    required this.newFollowers7d,
    required this.unreadMessages,
    required this.activeConversationsCount,
    required this.profileViews7d,
    required this.auctionViews7d,
    required this.marketItemViews7d,
  });

  factory EngagementSummaryInsights.fromJson(Map<String, dynamic> json) =>
      EngagementSummaryInsights(
        followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
        newFollowers7d:
            (json['new_followers_count_7d'] as num?)?.toInt() ?? 0,
        unreadMessages:
            (json['unread_messages_count'] as num?)?.toInt() ?? 0,
        activeConversationsCount:
            (json['active_conversations_count'] as num?)?.toInt() ?? 0,
        profileViews7d: (json['profile_views_7d'] as num?)?.toInt() ?? 0,
        auctionViews7d: (json['auction_views_7d'] as num?)?.toInt() ?? 0,
        marketItemViews7d:
            (json['market_item_views_7d'] as num?)?.toInt() ?? 0,
      );
}

class TrustSummaryInsights {
  final int badgesCount;
  final double averageRating;
  final int ratingsCount;
  final int recentReviewsCount7d;

  const TrustSummaryInsights({
    required this.badgesCount,
    required this.averageRating,
    required this.ratingsCount,
    required this.recentReviewsCount7d,
  });

  factory TrustSummaryInsights.fromJson(Map<String, dynamic> json) =>
      TrustSummaryInsights(
        badgesCount: (json['badges_count'] as num?)?.toInt() ?? 0,
        averageRating:
            double.tryParse('${json['average_rating'] ?? 0}') ?? 0.0,
        ratingsCount: (json['ratings_count'] as num?)?.toInt() ?? 0,
        recentReviewsCount7d:
            (json['recent_reviews_count_7d'] as num?)?.toInt() ?? 0,
      );
}

class PackageSummaryInsights {
  final int? activePackageId;
  final String? activePackageName;
  final int? activePackageRemainingPoints;
  final int? remainingAuctionQuota;
  final int? remainingMarketQuota;
  final int promotedAuctionsCount;
  final int promotedMarketCount;
  final DateTime? packageExpiryDate;

  const PackageSummaryInsights({
    required this.activePackageId,
    required this.activePackageName,
    required this.activePackageRemainingPoints,
    required this.remainingAuctionQuota,
    required this.remainingMarketQuota,
    required this.promotedAuctionsCount,
    required this.promotedMarketCount,
    required this.packageExpiryDate,
  });

  bool get isActive => activePackageName != null;

  factory PackageSummaryInsights.fromJson(Map<String, dynamic> json) {
    final activePackageJson = json['active_package'];
    int? packageId;
    String? packageName;
    int? packageRemainingPoints;
    if (activePackageJson is Map<String, dynamic>) {
      packageId = (activePackageJson['id'] as num?)?.toInt();
      packageName = activePackageJson['name'] as String?;
      packageRemainingPoints =
          (activePackageJson['remaining_points'] as num?)?.toInt();
    }
    return PackageSummaryInsights(
      activePackageId: packageId,
      activePackageName: packageName,
      activePackageRemainingPoints: packageRemainingPoints,
      remainingAuctionQuota:
          (json['remaining_auction_quota'] as num?)?.toInt(),
      remainingMarketQuota:
          (json['remaining_market_quota'] as num?)?.toInt(),
      promotedAuctionsCount:
          (json['promoted_auctions_count'] as num?)?.toInt() ?? 0,
      promotedMarketCount:
          (json['promoted_market_items_count'] as num?)?.toInt() ?? 0,
      packageExpiryDate: DateTime.tryParse('${json['package_expiry_date']}'),
    );
  }

  String get displayName {
    if (activePackageName == null || activePackageName!.isEmpty) {
      return 'بدون باقة';
    }
    return switch (activePackageName!) {
      'bronze' => 'برونزي',
      'silver' => 'فضي',
      'gold' => 'ذهبي',
      'platinum' => 'بلاتيني',
      _ => activePackageName!,
    };
  }
}

class SellerInsightsModel {
  final AuctionSummaryInsights auctionSummary;
  final MarketSummaryInsights marketSummary;
  final EngagementSummaryInsights engagementSummary;
  final TrustSummaryInsights trustSummary;
  final PackageSummaryInsights packageSummary;

  const SellerInsightsModel({
    required this.auctionSummary,
    required this.marketSummary,
    required this.engagementSummary,
    required this.trustSummary,
    required this.packageSummary,
  });

  factory SellerInsightsModel.fromJson(Map<String, dynamic> json) =>
      SellerInsightsModel(
        auctionSummary: AuctionSummaryInsights.fromJson(
            json['auction_summary'] as Map<String, dynamic>? ?? {}),
        marketSummary: MarketSummaryInsights.fromJson(
            json['market_summary'] as Map<String, dynamic>? ?? {}),
        engagementSummary: EngagementSummaryInsights.fromJson(
            json['engagement_summary'] as Map<String, dynamic>? ?? {}),
        trustSummary: TrustSummaryInsights.fromJson(
            json['trust_summary'] as Map<String, dynamic>? ?? {}),
        packageSummary: PackageSummaryInsights.fromJson(
            json['package_summary'] as Map<String, dynamic>? ?? {}),
      );
}
