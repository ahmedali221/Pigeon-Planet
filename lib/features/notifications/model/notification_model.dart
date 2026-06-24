enum NotificationType {
  chatMessageReceived,
  paymentRequestCreated,
  paymentRequestApproved,
  paymentRequestRejected,
  orderItemApproved,
  orderItemRejected,
  auctionWon,
  auctionOutbid,
  complaintCreated,
  complaintStatusUpdated,
  cashbackEarned,
  badgeAwarded,
  packageExpiringSoon,
  manualManagerNotification,
  auctionBidPlaced,
  auctionBuyNowSuccess,
  orderItemPendingSeller,
  orderItemAutoCancelled,
  unknown,
}

class NotificationActorProfile {
  final int id;
  final String type;
  final String? nickname;

  const NotificationActorProfile({
    required this.id,
    required this.type,
    this.nickname,
  });

  factory NotificationActorProfile.fromJson(Map<String, dynamic> json) {
    return NotificationActorProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      nickname: json['nickname'] as String?,
    );
  }
}

class NotificationModel {
  final int id;
  final String notificationType;
  final String title;
  final String body;
  final bool isRead;
  final DateTime created;
  final Map<String, dynamic> metadata;
  final NotificationActorProfile? actorProfile;
  final String? objectType;
  final int? objectId;
  final String? targetUrl;

  const NotificationModel({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.isRead,
    required this.created,
    this.metadata = const {},
    this.actorProfile,
    this.objectType,
    this.objectId,
    this.targetUrl,
  });

  NotificationType get type {
    switch (notificationType) {
      case 'chat_message_received':
        return NotificationType.chatMessageReceived;
      case 'payment_request_created':
        return NotificationType.paymentRequestCreated;
      case 'payment_request_approved':
        return NotificationType.paymentRequestApproved;
      case 'payment_request_rejected':
        return NotificationType.paymentRequestRejected;
      case 'order_item_approved':
        return NotificationType.orderItemApproved;
      case 'order_item_rejected':
        return NotificationType.orderItemRejected;
      case 'auction_won':
        return NotificationType.auctionWon;
      case 'auction_outbid':
        return NotificationType.auctionOutbid;
      case 'complaint_created':
        return NotificationType.complaintCreated;
      case 'complaint_status_updated':
        return NotificationType.complaintStatusUpdated;
      case 'cashback_earned':
        return NotificationType.cashbackEarned;
      case 'badge_awarded':
        return NotificationType.badgeAwarded;
      case 'package_expiring_soon':
        return NotificationType.packageExpiringSoon;
      case 'manual_manager_notification':
        return NotificationType.manualManagerNotification;
      case 'auction_bid_placed':
        return NotificationType.auctionBidPlaced;
      case 'auction_buy_now_success':
        return NotificationType.auctionBuyNowSuccess;
      case 'order_item_pending_seller':
        return NotificationType.orderItemPendingSeller;
      case 'order_item_auto_cancelled':
        return NotificationType.orderItemAutoCancelled;
      default:
        return NotificationType.unknown;
    }
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
    final actorJson = json['actor_profile'] as Map<String, dynamic>?;
    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      notificationType: json['notification_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: (json['body'] as String?)?.isNotEmpty == true
          ? json['body'] as String
          : '',
      isRead: json['is_read'] as bool? ?? (readAt != null),
      created: createdRaw != null
          ? DateTime.tryParse(createdRaw) ?? DateTime.now()
          : DateTime.now(),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
      actorProfile: actorJson != null
          ? NotificationActorProfile.fromJson(actorJson)
          : null,
      objectType: json['object_type'] as String?,
      objectId: (json['object_id'] as num?)?.toInt(),
      targetUrl: json['target_url'] as String?,
    );
  }

  NotificationModel markRead() => NotificationModel(
        id: id,
        notificationType: notificationType,
        title: title,
        body: body,
        isRead: true,
        created: created,
        metadata: metadata,
        actorProfile: actorProfile,
        objectType: objectType,
        objectId: objectId,
        targetUrl: targetUrl,
      );
}
