import 'package:equatable/equatable.dart';

class SellerHomeNotification extends Equatable {
  final String kind;
  final String title;
  final String createdAt;
  final String timeHint;
  final bool isNew;

  const SellerHomeNotification({
    required this.kind,
    required this.title,
    required this.createdAt,
    required this.timeHint,
    required this.isNew,
  });

  factory SellerHomeNotification.fromJson(Map<String, dynamic> j) {
    return SellerHomeNotification(
      kind: j['kind'] as String? ?? '',
      title: j['title'] as String? ?? '',
      createdAt: j['created_at'] as String? ?? '',
      timeHint: j['time_hint'] as String? ?? '',
      isNew: j['is_new'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [kind, title, createdAt, timeHint, isNew];
}

class SellerProviderNote extends Equatable {
  final String key;
  final String title;
  final String subtitle;
  final String accent;
  final bool done;

  const SellerProviderNote({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.done,
  });

  factory SellerProviderNote.fromJson(Map<String, dynamic> j) {
    return SellerProviderNote(
      key: j['key'] as String? ?? '',
      title: j['title'] as String? ?? '',
      subtitle: j['subtitle'] as String? ?? '',
      accent: j['accent'] as String? ?? 'primary',
      done: j['done'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [key, title, subtitle, accent, done];
}

class SellerHomeSummary extends Equatable {
  // ── Identity ─────────────────────────────────────────────────────────────
  final String nickname;
  final String balance;
  final String currency;
  final bool profileActivated;

  // ── Package ──────────────────────────────────────────────────────────────
  final String? subscriptionTier;
  final int? pointsBalance;
  final int remainingAuctionQuota;
  final int remainingMarketQuota;
  final String? packageExpiryDate;

  // ── Auction summary ───────────────────────────────────────────────────────
  final int activeLiveAuctions;
  final int auctionClosedCount;
  final int auctionEndingSoonCount;
  final int auctionSoldCount;
  final int totalBidsReceived;
  final int uniqueBiddersCount;
  final int pendingAuctionPayments;

  // ── Market summary ────────────────────────────────────────────────────────
  final int myActiveListings;
  final int marketSoldCount;
  final int pendingOrderItems;
  final int pendingMarketPayments;
  final int lowStockCount;

  // ── Engagement (7-day) ────────────────────────────────────────────────────
  final int followersCount;
  final int newFollowers7d;
  final int unreadMessages;
  final int activeConversations;
  final int profileViews7d;
  final int auctionViews7d;
  final int marketItemViews7d;

  // ── Trust ─────────────────────────────────────────────────────────────────
  final double? averageRating;
  final int ratingsCount;
  final int recentReviews7d;
  final int badgesCount;

  // ── Notifications / notes ─────────────────────────────────────────────────
  final List<SellerHomeNotification> notifications;
  final int notificationsNewCount;
  final List<SellerProviderNote> providerNotes;

  const SellerHomeSummary({
    required this.nickname,
    required this.balance,
    required this.currency,
    required this.profileActivated,
    this.subscriptionTier,
    this.pointsBalance,
    this.remainingAuctionQuota = 0,
    this.remainingMarketQuota = 0,
    this.packageExpiryDate,
    required this.activeLiveAuctions,
    this.auctionClosedCount = 0,
    this.auctionEndingSoonCount = 0,
    this.auctionSoldCount = 0,
    this.totalBidsReceived = 0,
    this.uniqueBiddersCount = 0,
    this.pendingAuctionPayments = 0,
    required this.myActiveListings,
    this.marketSoldCount = 0,
    required this.pendingOrderItems,
    this.pendingMarketPayments = 0,
    this.lowStockCount = 0,
    this.followersCount = 0,
    this.newFollowers7d = 0,
    this.unreadMessages = 0,
    this.activeConversations = 0,
    this.profileViews7d = 0,
    this.auctionViews7d = 0,
    this.marketItemViews7d = 0,
    this.averageRating,
    this.ratingsCount = 0,
    this.recentReviews7d = 0,
    this.badgesCount = 0,
    required this.notifications,
    required this.notificationsNewCount,
    required this.providerNotes,
  });

  /// Parses the nested 5-section response from `/insights/seller/home/`.
  factory SellerHomeSummary.fromJson(Map<String, dynamic> j) {
    final auc = j['auction_summary'] as Map<String, dynamic>? ?? {};
    final mkt = j['market_summary'] as Map<String, dynamic>? ?? {};
    final eng = j['engagement_summary'] as Map<String, dynamic>? ?? {};
    final trt = j['trust_summary'] as Map<String, dynamic>? ?? {};
    final pkg = j['package_summary'] as Map<String, dynamic>? ?? {};
    final activePkg = pkg['active_package'] as Map<String, dynamic>?;

    final notifs = (j['notifications'] as List<dynamic>? ?? [])
        .map((e) => SellerHomeNotification.fromJson(e as Map<String, dynamic>))
        .toList();
    final notes = (j['provider_notes'] as List<dynamic>? ?? [])
        .map((e) => SellerProviderNote.fromJson(e as Map<String, dynamic>))
        .toList();

    return SellerHomeSummary(
      nickname: j['nickname'] as String? ?? '',
      balance: j['balance'] as String? ?? '0',
      currency: j['currency'] as String? ?? 'EGP',
      profileActivated: j['profile_activated'] as bool? ?? true,
      // Package
      subscriptionTier: activePkg?['name'] as String?,
      pointsBalance: (activePkg?['remaining_points'] as num?)?.toInt(),
      remainingAuctionQuota: (pkg['remaining_auction_quota'] as num?)?.toInt() ?? 0,
      remainingMarketQuota: (pkg['remaining_market_quota'] as num?)?.toInt() ?? 0,
      packageExpiryDate: pkg['package_expiry_date'] as String?,
      // Auction
      activeLiveAuctions: (auc['active_count'] as num?)?.toInt() ?? 0,
      auctionClosedCount: (auc['closed_count'] as num?)?.toInt() ?? 0,
      auctionEndingSoonCount: (auc['ending_soon_count'] as num?)?.toInt() ?? 0,
      auctionSoldCount: (auc['sold_items_count'] as num?)?.toInt() ?? 0,
      totalBidsReceived: (auc['total_bids_received'] as num?)?.toInt() ?? 0,
      uniqueBiddersCount: (auc['unique_bidders_count'] as num?)?.toInt() ?? 0,
      pendingAuctionPayments: (auc['pending_payment_requests_count'] as num?)?.toInt() ?? 0,
      // Market
      myActiveListings: (mkt['active_listings_count'] as num?)?.toInt() ?? 0,
      marketSoldCount: (mkt['sold_items_count'] as num?)?.toInt() ?? 0,
      pendingOrderItems: (mkt['pending_order_items_count'] as num?)?.toInt() ?? 0,
      pendingMarketPayments: (mkt['pending_payment_requests_count'] as num?)?.toInt() ?? 0,
      lowStockCount: (mkt['low_stock_products_count'] as num?)?.toInt() ?? 0,
      // Engagement
      followersCount: (eng['followers_count'] as num?)?.toInt() ?? 0,
      newFollowers7d: (eng['new_followers_count_7d'] as num?)?.toInt() ?? 0,
      unreadMessages: (eng['unread_messages_count'] as num?)?.toInt() ?? 0,
      activeConversations: (eng['active_conversations_count'] as num?)?.toInt() ?? 0,
      profileViews7d: (eng['profile_views_7d'] as num?)?.toInt() ?? 0,
      auctionViews7d: (eng['auction_views_7d'] as num?)?.toInt() ?? 0,
      marketItemViews7d: (eng['market_item_views_7d'] as num?)?.toInt() ?? 0,
      // Trust
      averageRating: (trt['average_rating'] as num?)?.toDouble(),
      ratingsCount: (trt['ratings_count'] as num?)?.toInt() ?? 0,
      recentReviews7d: (trt['recent_reviews_count_7d'] as num?)?.toInt() ?? 0,
      badgesCount: (trt['badges_count'] as num?)?.toInt() ?? 0,
      // Notifications
      notifications: notifs,
      notificationsNewCount: (j['notifications_new_count'] as num?)?.toInt() ?? 0,
      providerNotes: notes,
    );
  }

  String get packageLabel =>
      subscriptionTier?.trim().isNotEmpty == true ? subscriptionTier! : 'بدون باقة';

  String get balanceDisplay {
    final b = balance.trim();
    return b.isEmpty ? '0' : b;
  }

  int get totalSoldCount => auctionSoldCount + marketSoldCount;

  int get totalPendingPayments => pendingAuctionPayments + pendingMarketPayments;

  @override
  List<Object?> get props => [
        nickname, balance, currency, profileActivated,
        subscriptionTier, pointsBalance, remainingAuctionQuota, remainingMarketQuota, packageExpiryDate,
        activeLiveAuctions, auctionClosedCount, auctionEndingSoonCount, auctionSoldCount,
        totalBidsReceived, uniqueBiddersCount, pendingAuctionPayments,
        myActiveListings, marketSoldCount, pendingOrderItems, pendingMarketPayments, lowStockCount,
        followersCount, newFollowers7d, unreadMessages, activeConversations,
        profileViews7d, auctionViews7d, marketItemViews7d,
        averageRating, ratingsCount, recentReviews7d, badgesCount,
        notifications, notificationsNewCount, providerNotes,
      ];
}
