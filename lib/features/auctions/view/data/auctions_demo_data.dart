import '../../model/auction_item_model.dart';
import '../../model/auction_model.dart';
import '../../model/bid_model.dart';
import '../../model/bird_summary_model.dart';

/// Typed demo data for the Auctions feature.
/// Use this instead of raw maps wherever AuctionModel / AuctionItemModel is needed.
class AuctionsDemoData {
  AuctionsDemoData._();

  // ── Birds ──────────────────────────────────────────────────────────────────

  static final BirdSummaryModel _bird1 = BirdSummaryModel(
    id: 101,
    name: 'الصاعقة الزرقاء',
    ringNumber: 'BE22-5048321',
    gender: 'male',
    colour: 'أزرق رمادي',
    birthday: DateTime(2022, 3, 15),
  );

  static final BirdSummaryModel _bird2 = BirdSummaryModel(
    id: 102,
    name: 'نجم الشمال',
    ringNumber: 'NL23-7712345',
    gender: 'female',
    colour: 'أبيض فضي',
    birthday: DateTime(2023, 1, 20),
  );

  static final BirdSummaryModel _bird3 = BirdSummaryModel(
    id: 103,
    name: 'ملك الصحراء',
    ringNumber: 'EG-2024-005678',
    gender: 'male',
    colour: 'بني ذهبي',
    birthday: DateTime(2024, 2, 10),
  );

  static final BirdSummaryModel _bird4 = BirdSummaryModel(
    id: 104,
    name: 'برق الغرب',
    ringNumber: 'EG-2024-001234',
    gender: 'male',
    colour: 'رمادي داكن',
    birthday: DateTime(2024, 4, 5),
  );

  static final BirdSummaryModel _bird5 = BirdSummaryModel(
    id: 105,
    name: 'أميرة الريح',
    ringNumber: 'NL-2023-887744',
    gender: 'female',
    colour: 'أبيض ناصع',
    birthday: DateTime(2023, 8, 18),
  );

  static final BirdSummaryModel _bird6 = BirdSummaryModel(
    id: 106,
    name: 'فارس الأطلس',
    ringNumber: 'BE-2024-112233',
    gender: 'male',
    colour: 'أزرق داكن',
    birthday: DateTime(2024, 1, 30),
  );

  static final BirdSummaryModel _bird7 = BirdSummaryModel(
    id: 107,
    name: 'درة الشرق',
    ringNumber: 'SA-2024-009900',
    gender: 'female',
    colour: 'بني فاتح',
    birthday: DateTime(2024, 3, 22),
  );

  static final BirdSummaryModel _bird8 = BirdSummaryModel(
    id: 108,
    name: 'سيف الريح',
    ringNumber: 'FR-2024-778899',
    gender: 'male',
    colour: 'أزرق فيروزي',
    birthday: DateTime(2024, 5, 1),
  );

  // ── Bids ───────────────────────────────────────────────────────────────────

  static final _now = DateTime.now();

  static List<BidModel> _bidsFor(int itemId, List<(int, String, double)> entries) =>
      entries.asMap().entries.map((e) {
        final idx = e.key;
        final (bidder, username, amount) = e.value;
        final isWinning = idx == entries.length - 1;
        return BidModel(
          id: itemId * 100 + idx,
          bidder: bidder,
          bidderUsername: username,
          amount: amount,
          created: _now.subtract(Duration(minutes: (entries.length - idx) * 15)),
          isWinningBid: isWinning,
        );
      }).toList();

  // ── Auction Items ──────────────────────────────────────────────────────────

  static AuctionItemModel _item(
    int id,
    int auctionId,
    String auctionTitle,
    BirdSummaryModel bird,
    double startingPrice,
    double currentPrice,
    String? highestBidder,
    List<(int, String, double)> bids, {
    bool isActive = true,
  }) =>
      AuctionItemModel(
        id: id,
        auctionId: auctionId,
        auctionTitle: auctionTitle,
        status: isActive ? 'active' : 'ended',
        startingPrice: startingPrice,
        currentPrice: currentPrice,
        currentHighestBidder: highestBidder,
        isActive: isActive,
        bird: bird,
        bids: _bidsFor(id, bids),
      );

  // ── Auctions ───────────────────────────────────────────────────────────────

  static final List<AuctionModel> auctions = [
    // 1 — Single active auction, Belgian champion line
    AuctionModel(
      id: 1,
      title: 'مزاد الصاعقة الزرقاء - خط Gaby Vandenabeele',
      description:
          'طائر نادر من أصول بلجيكية أصيلة. من خط Gaby Vandenabeele الأسطوري. '
          'حقق المركز الثالث في سباق 500 كم الوطني 2023. '
          'شهادات نسب موثقة كاملة ومعتمدة دولياً.',
      auctionType: 'single',
      auctionTypeDisplay: 'مزاد مفرد',
      status: 'active',
      statusDisplay: 'نشط',
      sellerNickname: 'مزرعة الأبطال الأوروبية',
      startTime: _now.subtract(const Duration(hours: 6)),
      endTime: _now.add(const Duration(hours: 18)),
      timeRemaining: 18 * 3600,
      isActive: true,
      isEnded: false,
      buyNowEnabled: true,
      buyNowPrice: 18000,
      minBidIncrement: 250,
      itemCount: 1,
      items: [
        _item(
          11, 1,
          'مزاد الصاعقة الزرقاء - خط Gaby Vandenabeele',
          _bird1,
          8000, 12750, 'خالد_الحربي',
          [
            (201, 'أحمد_الفارس', 8000),
            (202, 'سعود_العتيبي', 9500),
            (203, 'محمد_الكريم', 11000),
            (201, 'أحمد_الفارس', 12000),
            (204, 'خالد_الحربي', 12750),
          ],
        ),
      ],
    ),

    // 2 — Single active, Dutch champion female
    AuctionModel(
      id: 2,
      title: 'مزاد نجم الشمال - سلالة Van Loon الهولندية',
      description:
          'أنثى بطولية من خط Van Loon الهولندي الأصيل. '
          'تسعة سباقات دولية في سجلها، منها الميدالية الذهبية في البطولة الهولندية 2022. '
          'مثالية لتحسين الخطوط الجينية.',
      auctionType: 'single',
      auctionTypeDisplay: 'مزاد مفرد',
      status: 'active',
      statusDisplay: 'نشط',
      sellerNickname: 'مزرعة النجوم الهولندية',
      startTime: _now.subtract(const Duration(hours: 3)),
      endTime: _now.add(const Duration(hours: 44, minutes: 55)),
      timeRemaining: 44 * 3600 + 55 * 60,
      isActive: true,
      isEnded: false,
      buyNowEnabled: false,
      minBidIncrement: 500,
      itemCount: 1,
      items: [
        _item(
          21, 2,
          'مزاد نجم الشمال - سلالة Van Loon الهولندية',
          _bird2,
          5000, 9500, 'فهد_المطيري',
          [
            (205, 'نواف_السلطان', 5000),
            (206, 'يوسف_البكري', 7000),
            (207, 'فهد_المطيري', 9500),
          ],
        ),
      ],
    ),

    // 3 — Multi-item auction (Egyptian male + pair)
    AuctionModel(
      id: 3,
      title: 'مزاد متعدد - أبطال مصر 2024',
      description:
          'مزاد حصري يضم أفضل الطيور المصرية لهذا العام. '
          'ثلاثة طيور بشهادات موثقة من اتحاد الهواة المصري. '
          'فرصة نادرة للحصول على سلالات بطولية مصرية أصيلة.',
      auctionType: 'multi',
      auctionTypeDisplay: 'مزاد متعدد',
      status: 'active',
      statusDisplay: 'نشط',
      sellerNickname: 'نادي الزاجل المصري',
      startTime: _now.subtract(const Duration(hours: 12)),
      endTime: _now.add(const Duration(days: 2)),
      timeRemaining: 2 * 86400,
      isActive: true,
      isEnded: false,
      buyNowEnabled: false,
      minBidIncrement: 200,
      itemCount: 2,
      items: [
        _item(
          31, 3,
          'مزاد متعدد - أبطال مصر 2024',
          _bird3,
          3000, 7800, 'عمر_الشافعي',
          [
            (208, 'طارق_النجار', 3000),
            (209, 'علي_السيد', 5500),
            (208, 'طارق_النجار', 7000),
            (210, 'عمر_الشافعي', 7800),
          ],
        ),
        _item(
          32, 3,
          'مزاد متعدد - أبطال مصر 2024',
          _bird4,
          2500, 4600, 'رامي_عبدالله',
          [
            (211, 'رامي_عبدالله', 2500),
            (212, 'كريم_الأمين', 3800),
            (211, 'رامي_عبدالله', 4600),
          ],
        ),
      ],
    ),

    // 4 — Breeding pair auction
    AuctionModel(
      id: 4,
      title: 'زوج تربية - خط Vandenabeele البلجيكي الأصيل',
      description:
          'زوج تربية نادر من أصول Vandenabeele البلجيكية. '
          'الذكر حائز بطولة 2023، والأنثى من خط إنتاج قياسي. '
          'ضمان صحي سنة كاملة مع شهادات DNA موثقة.',
      auctionType: 'pair',
      auctionTypeDisplay: 'زوج تربية',
      status: 'active',
      statusDisplay: 'نشط',
      sellerNickname: 'بيت الحمام الذهبي',
      startTime: _now.subtract(const Duration(days: 1)),
      endTime: _now.add(const Duration(days: 1, hours: 23)),
      timeRemaining: 1 * 86400 + 23 * 3600,
      isActive: true,
      isEnded: false,
      buyNowEnabled: true,
      buyNowPrice: 75000,
      minBidIncrement: 1000,
      itemCount: 2,
      items: [
        _item(
          41, 4,
          'زوج تربية - خط Vandenabeele البلجيكي الأصيل',
          _bird5,
          15000, 42000, 'بندر_القحطاني',
          [
            (213, 'سلطان_العمري', 15000),
            (214, 'بدر_الزهراني', 25000),
            (215, 'بندر_القحطاني', 35000),
            (213, 'سلطان_العمري', 38000),
            (215, 'بندر_القحطاني', 42000),
          ],
        ),
        _item(
          42, 4,
          'زوج تربية - خط Vandenabeele البلجيكي الأصيل',
          _bird6,
          18000, 30000, 'سلطان_العمري',
          [
            (216, 'عادل_الرشيد', 18000),
            (213, 'سلطان_العمري', 24000),
            (216, 'عادل_الرشيد', 28000),
            (213, 'سلطان_العمري', 30000),
          ],
        ),
      ],
    ),

    // 5 — Racing single (Saudi)
    AuctionModel(
      id: 5,
      title: 'مزاد سباقات - درة الشرق السعودية',
      description:
          'طائر سباقات نخبة من سلالة سعودية-بلجيكية مهجنة. '
          'سرعة قياسية 108 كم/ساعة في مسافة 300 كم. '
          'مسجل في الاتحاد السعودي لهواة تربية الحمام.',
      auctionType: 'racing',
      auctionTypeDisplay: 'سباق',
      status: 'active',
      statusDisplay: 'نشط',
      sellerNickname: 'نادي الزاجل السعودي',
      startTime: _now.subtract(const Duration(hours: 8)),
      endTime: _now.add(const Duration(hours: 2, minutes: 55)),
      timeRemaining: 2 * 3600 + 55 * 60,
      isActive: true,
      isEnded: false,
      buyNowEnabled: false,
      minBidIncrement: 150,
      itemCount: 1,
      items: [
        _item(
          51, 5,
          'مزاد سباقات - درة الشرق السعودية',
          _bird7,
          2000, 5500, 'حسين_الدوسري',
          [
            (217, 'حسين_الدوسري', 2000),
            (218, 'ماجد_السيف', 3200),
            (217, 'حسين_الدوسري', 4500),
            (219, 'وليد_الغامدي', 5000),
            (217, 'حسين_الدوسري', 5500),
          ],
        ),
      ],
    ),

    // 6 — High-value French import, few bids
    AuctionModel(
      id: 6,
      title: 'مزاد حصري - سيف الريح الفرنسي المستورد',
      description:
          'طائر نادر مستورد من فرنسا بشهادة الاتحاد الفرنسي للزاجل. '
          'خط دم De Rauw-Sablon الأصيل. سجل 5 انتصارات دولية في 2023-2024. '
          'مناسب لمحبي النخبة والجودة الأوروبية.',
      auctionType: 'single',
      auctionTypeDisplay: 'مزاد مفرد',
      status: 'active',
      statusDisplay: 'نشط',
      sellerNickname: 'الاتحاد الفرنسي للزاجل',
      startTime: _now.subtract(const Duration(hours: 1)),
      endTime: _now.add(const Duration(hours: 6, minutes: 50)),
      timeRemaining: 6 * 3600 + 50 * 60,
      isActive: true,
      isEnded: false,
      buyNowEnabled: true,
      buyNowPrice: 20000,
      minBidIncrement: 500,
      itemCount: 1,
      items: [
        _item(
          61, 6,
          'مزاد حصري - سيف الريح الفرنسي المستورد',
          _bird8,
          10000, 14000, 'نبيل_حسن',
          [
            (220, 'نبيل_حسن', 10000),
            (221, 'جاسم_الكواري', 12500),
            (220, 'نبيل_حسن', 14000),
          ],
        ),
      ],
    ),

    // 7 — Ended auction (for history/ended tab)
    AuctionModel(
      id: 7,
      title: 'مزاد منتهي - ملكة السباقات NL23-1925764',
      description:
          'مزاد انتهى بنجاح. بطلة وطنية بسرعة قياسية 110 كم/ساعة.',
      auctionType: 'single',
      auctionTypeDisplay: 'مزاد مفرد',
      status: 'ended',
      statusDisplay: 'منتهي',
      sellerNickname: 'عزيزة النسور الذهبية',
      startTime: _now.subtract(const Duration(days: 3)),
      endTime: _now.subtract(const Duration(hours: 2)),
      timeRemaining: 0,
      isActive: false,
      isEnded: true,
      buyNowEnabled: false,
      minBidIncrement: 300,
      itemCount: 1,
      items: [
        _item(
          71, 7,
          'مزاد منتهي - ملكة السباقات NL23-1925764',
          BirdSummaryModel(
            id: 109,
            name: 'ملكة السباقات',
            ringNumber: 'NL23-1925764',
            gender: 'female',
            colour: 'أبيض أزرق',
            birthday: DateTime(2023, 5, 10),
          ),
          5000, 9800, 'أحمد_الفارس',
          [
            (222, 'خالد_الحربي', 5000),
            (223, 'نواف_السلطان', 7000),
            (222, 'خالد_الحربي', 8500),
            (201, 'أحمد_الفارس', 9800),
          ],
          isActive: false,
        ),
      ],
    ),
  ];

  /// Active auctions only
  static List<AuctionModel> get activeAuctions =>
      auctions.where((a) => a.isActive).toList();

  /// Ended auctions only
  static List<AuctionModel> get endedAuctions =>
      auctions.where((a) => a.isEnded).toList();
}
