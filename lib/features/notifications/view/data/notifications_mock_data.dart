enum NotificationType { auctionWon, bidAccepted, newBid, newBadge }

class NotificationItem {
  final String title;
  final String body;
  final String timeAgo;
  final bool isRead;
  final NotificationType type;
  final String tag; // 'مشتري' or 'بائع' or 'عام'
  final int? apiId;

  const NotificationItem({
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.isRead,
    required this.type,
    required this.tag,
    this.apiId,
  });
}

class NotificationsMockData {
  static const List<NotificationItem> buyerNotifications = [
    NotificationItem(
      title: 'مبروك! فزت بالمزاد 🎉',
      body: "تهانينا! أنت الفائز الرسمي بمزاد 'الماسة الزرقاء' بمبلغ 28,500 ج.م. يرجى المتابعة للدفع.",
      timeAgo: 'منذ دقيقة',
      isRead: false,
      type: NotificationType.auctionWon,
      tag: 'مشتري',
    ),
    NotificationItem(
      title: 'تم قبول مزايدتك',
      body: 'DV01769 تم قبول مزايدتك المشروطة على حمام بلجيكي',
      timeAgo: 'منذ 5 دقائق',
      isRead: false,
      type: NotificationType.bidAccepted,
      tag: 'مشتري',
    ),
    NotificationItem(
      title: 'مزايدة جديدة',
      body: 'تمت مزايدة أعلى على الطائر الذي تتابعه',
      timeAgo: 'منذ 15 دقيقة',
      isRead: false,
      type: NotificationType.newBid,
      tag: 'مشتري',
    ),
    NotificationItem(
      title: 'وسام جديد! ⚡',
      body: "حصلت على وسام 'مشتري موثوق'",
      timeAgo: 'منذ ساعة',
      isRead: false,
      type: NotificationType.newBadge,
      tag: 'مشتري',
    ),
    NotificationItem(
      title: 'تم قبول مزايدتك',
      body: 'DV01234 تم قبول مزايدتك على حمام زاجل مصري',
      timeAgo: 'منذ 3 ساعات',
      isRead: true,
      type: NotificationType.bidAccepted,
      tag: 'مشتري',
    ),
    NotificationItem(
      title: 'مزايدة جديدة',
      body: 'تمت مزايدة أعلى على طائرك المفضل',
      timeAgo: 'منذ يوم',
      isRead: true,
      type: NotificationType.newBid,
      tag: 'مشتري',
    ),
    NotificationItem(
      title: 'مبروك! فزت بالمزاد 🎉',
      body: "تهانينا! أنت الفائز الرسمي بمزاد 'الملكي الأبيض' بمبلغ 12,000 ج.م.",
      timeAgo: 'منذ يومين',
      isRead: true,
      type: NotificationType.auctionWon,
      tag: 'مشتري',
    ),
  ];

  static const List<NotificationItem> sellerNotifications = [
    NotificationItem(
      title: 'مزايدة جديدة على طائرك',
      body: 'تلقى طائرك DV00987 مزايدة جديدة بمبلغ 5,200 ج.م.',
      timeAgo: 'منذ دقيقتين',
      isRead: false,
      type: NotificationType.newBid,
      tag: 'بائع',
    ),
    NotificationItem(
      title: 'انتهى المزاد بنجاح',
      body: "تم بيع طائرك 'النسر الذهبي' بمبلغ 18,000 ج.م. يرجى التواصل مع المشتري.",
      timeAgo: 'منذ 30 دقيقة',
      isRead: false,
      type: NotificationType.auctionWon,
      tag: 'بائع',
    ),
    NotificationItem(
      title: 'وسام جديد! ⚡',
      body: "حصلت على وسام 'بائع متميز'",
      timeAgo: 'منذ 2 ساعة',
      isRead: true,
      type: NotificationType.newBadge,
      tag: 'بائع',
    ),
  ];
}
