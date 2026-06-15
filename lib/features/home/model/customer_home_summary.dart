import 'package:equatable/equatable.dart';

import 'seller_home_summary.dart';

class CustomerHomeSummary extends Equatable {
  final String nickname;
  final String balance;
  final String currency;
  final int openOrders;
  final int pendingOrderItems;
  final List<SellerHomeNotification> notifications;
  final int notificationsNewCount;

  const CustomerHomeSummary({
    required this.nickname,
    required this.balance,
    required this.currency,
    required this.openOrders,
    required this.pendingOrderItems,
    required this.notifications,
    required this.notificationsNewCount,
  });

  factory CustomerHomeSummary.fromJson(Map<String, dynamic> j) {
    final notifs = (j['notifications'] as List<dynamic>? ?? [])
        .map((e) => SellerHomeNotification.fromJson(e as Map<String, dynamic>))
        .toList();
    return CustomerHomeSummary(
      nickname: j['nickname'] as String? ?? '',
      balance: j['balance'] as String? ?? '0',
      currency: j['currency'] as String? ?? 'EGP',
      openOrders: (j['open_orders'] as num?)?.toInt() ?? 0,
      pendingOrderItems: (j['pending_order_items'] as num?)?.toInt() ?? 0,
      notifications: notifs,
      notificationsNewCount:
          (j['notifications_new_count'] as num?)?.toInt() ?? 0,
    );
  }

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
    openOrders,
    pendingOrderItems,
    notifications,
    notificationsNewCount,
  ];
}
