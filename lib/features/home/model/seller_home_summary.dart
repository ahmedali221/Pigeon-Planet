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
  final String nickname;
  final String balance;
  final String currency;
  final String? subscriptionTier;
  final int? pointsBalance;
  final bool profileActivated;
  final int activeLiveAuctions;
  final int myActiveListings;
  final int salesToday;
  final int pendingOrderItems;
  final List<SellerHomeNotification> notifications;
  final int notificationsNewCount;
  final List<SellerProviderNote> providerNotes;

  const SellerHomeSummary({
    required this.nickname,
    required this.balance,
    required this.currency,
    this.subscriptionTier,
    this.pointsBalance,
    required this.profileActivated,
    required this.activeLiveAuctions,
    required this.myActiveListings,
    required this.salesToday,
    required this.pendingOrderItems,
    required this.notifications,
    required this.notificationsNewCount,
    required this.providerNotes,
  });

  factory SellerHomeSummary.fromJson(Map<String, dynamic> j) {
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
      subscriptionTier: j['subscription_tier'] as String?,
      pointsBalance: (j['points_balance'] as num?)?.toInt(),
      profileActivated: j['profile_activated'] as bool? ?? false,
      activeLiveAuctions: (j['active_live_auctions'] as num?)?.toInt() ?? 0,
      myActiveListings: (j['my_active_listings'] as num?)?.toInt() ?? 0,
      salesToday: (j['sales_today'] as num?)?.toInt() ?? 0,
      pendingOrderItems: (j['pending_order_items'] as num?)?.toInt() ?? 0,
      notifications: notifs,
      notificationsNewCount:
          (j['notifications_new_count'] as num?)?.toInt() ?? 0,
      providerNotes: notes,
    );
  }

  String get packageLabel => subscriptionTier?.trim().isNotEmpty == true
      ? subscriptionTier!
      : 'بدون باقة';

  String get balanceDisplay {
    final b = balance.trim();
    if (b.isEmpty) return '0';
    return b;
  }

  @override
  List<Object?> get props => [
    nickname,
    balance,
    currency,
    subscriptionTier,
    pointsBalance,
    profileActivated,
    activeLiveAuctions,
    myActiveListings,
    salesToday,
    pendingOrderItems,
    notifications,
    notificationsNewCount,
    providerNotes,
  ];
}
