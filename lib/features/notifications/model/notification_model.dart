enum NotificationType { auctionWon, bidAccepted, newBid, newBadge, payment, order }

class NotificationModel {
  final int id;
  final String kind;
  final String title;
  final String body;
  final bool isRead;
  final String profileType; // 'Seller' | 'Customer' | 'All' | ''
  final DateTime created;

  const NotificationModel({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.isRead,
    required this.profileType,
    required this.created,
  });

  // ── Computed UI properties ────────────────────────────────────────────────

  NotificationType get type {
    final k = kind.toLowerCase();
    if (k.contains('won') || k.contains('sold') || k.contains('auction')) {
      return NotificationType.auctionWon;
    }
    if (k.contains('payment')) return NotificationType.payment;
    if (k.contains('order')) return NotificationType.order;
    if (k.contains('accept') || k.contains('bid')) return NotificationType.bidAccepted;
    if (k.contains('badge') || k.contains('وسام')) return NotificationType.newBadge;
    return NotificationType.newBid;
  }

  String get tag {
    if (profileType == 'Seller') return 'بائع';
    if (profileType == 'Customer') return 'مشتري';
    return 'عام';
  }

  String get timeAgo {
    final now = DateTime.now().toUtc();
    var secs = now.difference(created.toUtc()).inSeconds;
    if (secs < 0) secs = 0;
    if (secs < 60) return 'الآن';
    if (secs < 3600) {
      final m = secs ~/ 60;
      return m == 1 ? 'منذ دقيقة' : 'منذ $m دقيقة';
    }
    if (secs < 86400) {
      final h = secs ~/ 3600;
      return h == 1 ? 'منذ ساعة' : 'منذ $h ساعة';
    }
    final d = secs ~/ 86400;
    return d == 1 ? 'منذ يوم' : 'منذ $d يوم';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final readAt = json['read_at'];
    final createdRaw = json['created'] as String?;
    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: (json['body'] as String?)?.isNotEmpty == true
          ? json['body'] as String
          : ' ',
      isRead: json['is_read'] as bool? ?? (readAt != null),
      profileType: json['profile_type'] as String? ?? 'All',
      created: createdRaw != null
          ? DateTime.tryParse(createdRaw) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  NotificationModel markRead() => NotificationModel(
        id: id,
        kind: kind,
        title: title,
        body: body,
        isRead: true,
        profileType: profileType,
        created: created,
      );
}
