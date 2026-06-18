import '../../model/notification_model.dart';

class NotificationsMockData {
  static List<NotificationModel> get buyerNotifications => [
        NotificationModel(
          id: 0,
          kind: 'auction_won',
          title: 'مبروك! فزت بالمزاد 🎉',
          body: "تهانينا! أنت الفائز الرسمي بمزاد 'الماسة الزرقاء' بمبلغ 28,500 ج.م. يرجى المتابعة للدفع.",
          isRead: false,
          profileType: 'Customer',
          created: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        NotificationModel(
          id: 0,
          kind: 'bid_accepted',
          title: 'تم قبول مزايدتك',
          body: 'DV01769 تم قبول مزايدتك المشروطة على حمام بلجيكي',
          isRead: false,
          profileType: 'Customer',
          created: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        NotificationModel(
          id: 0,
          kind: 'new_bid',
          title: 'مزايدة جديدة',
          body: 'تمت مزايدة أعلى على الطائر الذي تتابعه',
          isRead: false,
          profileType: 'Customer',
          created: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        NotificationModel(
          id: 0,
          kind: 'badge',
          title: 'وسام جديد! ⚡',
          body: "حصلت على وسام 'مشتري موثوق'",
          isRead: false,
          profileType: 'Customer',
          created: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        NotificationModel(
          id: 0,
          kind: 'bid_accepted',
          title: 'تم قبول مزايدتك',
          body: 'DV01234 تم قبول مزايدتك على حمام زاجل مصري',
          isRead: true,
          profileType: 'Customer',
          created: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        NotificationModel(
          id: 0,
          kind: 'new_bid',
          title: 'مزايدة جديدة',
          body: 'تمت مزايدة أعلى على طائرك المفضل',
          isRead: true,
          profileType: 'Customer',
          created: DateTime.now().subtract(const Duration(days: 1)),
        ),
        NotificationModel(
          id: 0,
          kind: 'auction_won',
          title: 'مبروك! فزت بالمزاد 🎉',
          body: "تهانينا! أنت الفائز الرسمي بمزاد 'الملكي الأبيض' بمبلغ 12,000 ج.م.",
          isRead: true,
          profileType: 'Customer',
          created: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

  static List<NotificationModel> get sellerNotifications => [
        NotificationModel(
          id: 0,
          kind: 'new_bid',
          title: 'مزايدة جديدة على طائرك',
          body: 'تلقى طائرك DV00987 مزايدة جديدة بمبلغ 5,200 ج.م.',
          isRead: false,
          profileType: 'Seller',
          created: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        NotificationModel(
          id: 0,
          kind: 'auction_sold',
          title: 'انتهى المزاد بنجاح',
          body: "تم بيع طائرك 'النسر الذهبي' بمبلغ 18,000 ج.م. يرجى التواصل مع المشتري.",
          isRead: false,
          profileType: 'Seller',
          created: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        NotificationModel(
          id: 0,
          kind: 'badge',
          title: 'وسام جديد! ⚡',
          body: "حصلت على وسام 'بائع متميز'",
          isRead: true,
          profileType: 'Seller',
          created: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

  static List<NotificationModel> forTab(int tabIndex) =>
      tabIndex == 0 ? buyerNotifications : sellerNotifications;
}
