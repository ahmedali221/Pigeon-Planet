import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../model/datasources/points_remote_datasource.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

class PointsSystemModal extends StatelessWidget {
  final int pointsBalance;
  final bool isSeller;

  const PointsSystemModal({
    super.key,
    required this.pointsBalance,
    required this.isSeller,
  });

  static void show(
    BuildContext context, {
    int pointsBalance = 0,
    bool isSeller = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PointsSystemModal(
        pointsBalance: pointsBalance,
        isSeller: isSeller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (_, controller) => _ModalBody(
        pointsBalance: pointsBalance,
        isSeller: isSeller,
      ),
    );
  }
}

// ── Main body with tabs ───────────────────────────────────────────────────────

class _ModalBody extends StatefulWidget {
  final int pointsBalance;
  final bool isSeller;

  const _ModalBody({
    required this.pointsBalance,
    required this.isSeller,
  });

  @override
  State<_ModalBody> createState() => _ModalBodyState();
}

class _ModalBodyState extends State<_ModalBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final Future<LoyaltySnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
    _snapshotFuture = sl<PointsRemoteDataSource>().fetchSnapshot(
      includePackageBalance: widget.isSeller,
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LoyaltySnapshot>(
      future: _snapshotFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting && data == null;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.pageBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────────
              _ModalHeader(
                tabController: _tab,
                pointsBalance: data?.balance ?? widget.pointsBalance,
              ),

              _BalanceBreakdown(
                totalBalance: data?.balance ?? widget.pointsBalance,
                loyaltyBalance: data?.loyaltyBalance,
                packageBalance: data?.packageBalance,
              ),

              if (snapshot.hasError)
                const _InlineNotice(
                  icon: Icons.info_outline_rounded,
                  text: 'تعذر تحميل بيانات الولاء من الخادم',
                ),

              // ── Tab views ───────────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _PointsTab(
                      isLoading: isLoading,
                      transactions: data?.transactions ?? const [],
                    ),
                    _RewardsTab(
                      isLoading: isLoading,
                      badges: data?.badges ?? const [],
                      catalog: data?.catalog ?? const [],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ModalHeader extends StatelessWidget {
  final TabController tabController;
  final int pointsBalance;

  const _ModalHeader({
    required this.tabController,
    required this.pointsBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                // coin icon (rightmost)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نظام PP Coins',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'اكسب نقاطاً واستبدلها بجوائز حصرية',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // current balance chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'رصيدك الحالي',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '$pointsBalance نقطة',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.orange,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              tabs: const [
                Tab(text: '🪙  النقاط'),
                Tab(text: '🎁  الجوائز'),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Tab 1: Points ─────────────────────────────────────────────────────────────

class _BalanceBreakdown extends StatelessWidget {
  final int totalBalance;
  final int? loyaltyBalance;
  final int? packageBalance;

  const _BalanceBreakdown({
    required this.totalBalance,
    required this.loyaltyBalance,
    required this.packageBalance,
  });

  @override
  Widget build(BuildContext context) {
    final packagePoints = packageBalance ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _BalanceRow(
            icon: Icons.account_balance_wallet_rounded,
            label: 'إجمالي النقاط',
            value: totalBalance,
            color: AppColors.primary,
            isStrong: true,
          ),
          const Divider(height: 18),
          _BalanceRow(
            icon: Icons.card_giftcard_rounded,
            label: 'نقاط الولاء',
            value: loyaltyBalance ?? 0,
            color: AppColors.orange,
          ),
          if (packagePoints > 0) ...[
            const SizedBox(height: 8),
            _BalanceRow(
              icon: Icons.inventory_2_rounded,
              label: 'نقاط الباقة',
              value: packagePoints,
              color: AppColors.blue,
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final bool isStrong;

  const _BalanceRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isStrong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isStrong ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: isStrong ? 14 : 12,
              fontWeight: isStrong ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
        Text(
          '$value نقطة',
          style: TextStyle(
            color: color,
            fontSize: isStrong ? 16 : 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PointsTab extends StatelessWidget {
  final bool isLoading;
  final List<PointTransactionModel> transactions;

  const _PointsTab({required this.isLoading, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle(icon: '•', label: 'سجل النقاط'),
        const SizedBox(height: 10),
        if (isLoading)
          const _LoadingCard()
        else if (transactions.isEmpty)
          const _InlineNotice(
            icon: Icons.receipt_long_rounded,
            text: 'لا توجد معاملات نقاط بعد',
          )
        else
          ...transactions
              .take(5)
              .map((tx) => _TransactionTile(transaction: tx)),

        const SizedBox(height: 20),

        // How to earn
        _SectionTitle(icon: '⚡', label: 'كيف تكسب نقاطاً؟'),
        const SizedBox(height: 10),
        ..._earnItems.map((e) => _EarnTile(item: e)),

        const SizedBox(height: 20),

        // Points value table
        _SectionTitle(icon: '📊', label: 'قيمة النقاط'),
        const SizedBox(height: 10),
        _PointsValueTable(),

        const SizedBox(height: 20),

        // Note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.orangeLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: const [
              Text('💡', style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'النقاط صالحة لمدة سنة من تاريخ الكسب. تُضاف تلقائياً بعد إتمام كل عملية.',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// earn items data
const _earnItems = [
  _EarnItem(
    icon: Icons.gavel_rounded,
    color: AppColors.primary,
    colorBg: AppColors.primaryLight,
    title: 'إتمام بيع أو شراء',
    subtitle: 'لكل صفقة مكتملة',
    points: 100,
  ),
  _EarnItem(
    icon: Icons.bolt_rounded,
    color: AppColors.orange,
    colorBg: AppColors.orangeLight,
    title: 'سداد في الوقت المحدد',
    subtitle: 'خلال مهلة الدفع',
    points: 50,
  ),
  _EarnItem(
    icon: Icons.star_rounded,
    color: AppColors.orange,
    colorBg: AppColors.orangeLight,
    title: 'تقييم 5 نجوم',
    subtitle: 'من المشتري أو البائع',
    points: 30,
  ),
  _EarnItem(
    icon: Icons.person_add_rounded,
    color: AppColors.purple,
    colorBg: AppColors.purpleLight,
    title: 'دعوة صديق',
    subtitle: 'عند تسجيله وإتمام أول صفقة',
    points: 30,
  ),
  _EarnItem(
    icon: Icons.badge_rounded,
    color: AppColors.blue,
    colorBg: AppColors.blueLight,
    title: 'إضافة هوية رقمية للطائر',
    subtitle: 'أول مرة لكل طائر',
    points: 20,
  ),
  _EarnItem(
    icon: Icons.share_rounded,
    color: AppColors.primary,
    colorBg: AppColors.primaryLight,
    title: 'مشاركة مزاد',
    subtitle: 'عبر واتساب أو تويتر',
    points: 10,
  ),
  _EarnItem(
    icon: Icons.login_rounded,
    color: AppColors.textSecondary,
    colorBg: AppColors.inputBg,
    title: 'تسجيل الدخول اليومي',
    subtitle: 'مرة واحدة يومياً',
    points: 5,
  ),
];

class _EarnItem {
  final IconData icon;
  final Color color;
  final Color colorBg;
  final String title;
  final String subtitle;
  final int points;
  const _EarnItem({
    required this.icon,
    required this.color,
    required this.colorBg,
    required this.title,
    required this.subtitle,
    required this.points,
  });
}

class _EarnTile extends StatelessWidget {
  final _EarnItem item;
  const _EarnTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // icon (rightmost)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.colorBg,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // points badge (leftmost)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+${item.points}',
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.orange,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsValueTable extends StatelessWidget {
  const _PointsValueTable();

  static const _rows = [
    (50, 'خصم 5 ريال على رسوم النشر'),
    (100, 'خصم 10 ريال على أي صفقة'),
    (200, 'اشتراك مجاني لمدة أسبوع'),
    (500, 'ترقية إعلان مجانية × 2'),
    (750, 'شارة "بائع موثوق" لمدة شهر'),
    (1000, 'اشتراك مجاني لمدة شهر كامل'),
    (2500, 'إعلان مميز على الصفحة الرئيسية'),
    (5000, 'عضوية VIP لمدة 3 أشهر'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(_rows.length, (i) {
          final (pts, label) = _rows[i];
          final isLast = i == _rows.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    // points (rightmost)
                    Container(
                      width: 64,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: _milestoneColor(pts).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.monetization_on_rounded,
                            color: AppColors.orange,
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$pts',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _milestoneColor(pts),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 13,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 14, endIndent: 14),
            ],
          );
        }),
      ),
    );
  }

  static Color _milestoneColor(int pts) {
    if (pts >= 2500) return AppColors.purple;
    if (pts >= 1000) return AppColors.blue;
    if (pts >= 500) return AppColors.orange;
    return AppColors.primary;
  }
}

// ── Tab 2: Rewards ────────────────────────────────────────────────────────────

class _RewardsTab extends StatelessWidget {
  final bool isLoading;
  final List<BadgeAwardModel> badges;
  final List<BadgeCatalogItem> catalog;

  const _RewardsTab({
    required this.isLoading,
    required this.badges,
    required this.catalog,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle(icon: '•', label: 'شاراتي'),
        const SizedBox(height: 10),
        if (isLoading)
          const _LoadingCard()
        else if (badges.isEmpty)
          const _InlineNotice(
            icon: Icons.workspace_premium_rounded,
            text: 'لا توجد شارات مكتسبة بعد',
          )
        else
          ...badges.take(5).map((badge) => _BadgeAwardTile(badge: badge)),

        const SizedBox(height: 20),

        // Badge catalog from backend
        if (!isLoading && catalog.isNotEmpty) ...[
          const _SectionTitle(icon: '🏅', label: 'الشارات المتاحة'),
          const SizedBox(height: 10),
          ...catalog.map((item) => _BadgeCatalogTile(
                item: item,
                earned: badges.any((b) => b.badgeType == item.badgeType),
              )),
          const SizedBox(height: 20),
        ],

        // How to redeem
        _SectionTitle(icon: '🎁', label: 'كيف تحصل على جائزة؟'),
        const SizedBox(height: 10),
        _HowToRedeemCard(),

        const SizedBox(height: 20),

        // Rewards catalogue
        _SectionTitle(icon: '🏆', label: 'الجوائز المتاحة'),
        const SizedBox(height: 10),
        ..._rewardCatalogue.map((r) => _RewardCard(reward: r)),

        const SizedBox(height: 20),

        // Tiers
        _SectionTitle(icon: '⭐', label: 'مستويات العضوية'),
        const SizedBox(height: 10),
        _TiersCard(),

        const SizedBox(height: 16),
      ],
    );
  }
}

const _rewardCatalogue = [
  _Reward(
    emoji: '🎟️',
    title: 'تخفيض على رسوم المزاد',
    subtitle: 'خصم 10% على رسوم نشر أي مزاد',
    cost: 100,
    category: 'خصومات',
    categoryColor: AppColors.primary,
  ),
  _Reward(
    emoji: '📦',
    title: 'اشتراك أسبوعي مجاني',
    subtitle: 'اشتراك في باقة البائع الأساسية لمدة 7 أيام',
    cost: 200,
    category: 'اشتراكات',
    categoryColor: AppColors.blue,
  ),
  _Reward(
    emoji: '🔝',
    title: 'ترقية إعلان',
    subtitle: 'ظهور إعلانك في أعلى نتائج البحث لمدة 3 أيام',
    cost: 500,
    category: 'ترويج',
    categoryColor: AppColors.orange,
  ),
  _Reward(
    emoji: '✅',
    title: 'شارة البائع الموثوق',
    subtitle: 'شارة زرقاء تظهر بجانب اسمك لمدة شهر',
    cost: 750,
    category: 'مميزات',
    categoryColor: AppColors.purple,
  ),
  _Reward(
    emoji: '🌟',
    title: 'اشتراك شهري مجاني',
    subtitle: 'اشتراك في باقة البائع الاحترافية لمدة شهر',
    cost: 1000,
    category: 'اشتراكات',
    categoryColor: AppColors.blue,
  ),
  _Reward(
    emoji: '📣',
    title: 'إعلان مميز - الصفحة الرئيسية',
    subtitle: 'ظهور مزادك في بانر الصفحة الرئيسية لمدة يوم',
    cost: 2500,
    category: 'ترويج',
    categoryColor: AppColors.orange,
  ),
  _Reward(
    emoji: '👑',
    title: 'عضوية VIP',
    subtitle: 'جميع المزايا + دعم أولوية + خصم دائم 15%',
    cost: 5000,
    category: 'VIP',
    categoryColor: Color(0xFFD4A017),
  ),
];

class _Reward {
  final String emoji;
  final String title;
  final String subtitle;
  final int cost;
  final String category;
  final Color categoryColor;
  const _Reward({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.cost,
    required this.category,
    required this.categoryColor,
  });
}

class _RewardCard extends StatelessWidget {
  final _Reward reward;
  const _RewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // emoji circle (rightmost)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: reward.categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(reward.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reward.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: reward.categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          reward.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: reward.categoryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    reward.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // cost + redeem button
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: AppColors.orange,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${reward.cost} نقطة',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showComingSoon(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryDark,
                                AppColors.primary,
                              ],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'استبدال',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('قريباً — ميزة الاستبدال قيد التطوير'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HowToRedeemCard extends StatelessWidget {
  const _HowToRedeemCard();

  static const _steps = [
    (
      icon: Icons.monetization_on_rounded,
      color: AppColors.orange,
      text: 'اكسب نقاطاً من خلال إتمام الصفقات والأنشطة اليومية',
    ),
    (
      icon: Icons.search_rounded,
      color: AppColors.blue,
      text: 'اختر الجائزة التي تريدها من الكتالوج أدناه',
    ),
    (
      icon: Icons.touch_app_rounded,
      color: AppColors.primary,
      text: 'اضغط "استبدال" وسيتم خصم النقاط وتفعيل الجائزة فوراً',
    ),
    (
      icon: Icons.check_circle_rounded,
      color: AppColors.purple,
      text: 'تظهر الجائزة تلقائياً في حسابك خلال دقائق',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(_steps.length, (i) {
          final s = _steps[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // step number (rightmost)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: s.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        s.text,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(s.icon, color: s.color, size: 20),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TiersCard extends StatelessWidget {
  const _TiersCard();

  static const _tiers = [
    (
      emoji: '🥉',
      name: 'برونزي',
      range: '0 – 499 نقطة',
      color: Color(0xFFCD7F32),
      bg: Color(0xFFFFF8F0),
    ),
    (
      emoji: '🥈',
      name: 'فضي',
      range: '500 – 1,999 نقطة',
      color: Color(0xFF9E9E9E),
      bg: Color(0xFFF5F5F5),
    ),
    (
      emoji: '🥇',
      name: 'ذهبي',
      range: '2,000 – 4,999 نقطة',
      color: Color(0xFFD4A017),
      bg: Color(0xFFFFFDE7),
    ),
    (
      emoji: '💎',
      name: 'VIP',
      range: '5,000+ نقطة',
      color: AppColors.purple,
      bg: AppColors.purpleLight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(_tiers.length, (i) {
          final t = _tiers[i];
          final isLast = i == _tiers.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // emoji + name (rightmost)
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: t.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          t.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: t.color,
                            ),
                          ),
                          Text(
                            t.range,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: t.color,
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 14, endIndent: 14),
            ],
          );
        }),
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InlineNotice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final PointTransactionModel transaction;

  const _TransactionTile({required this.transaction});

  bool get _isEarn => transaction.transactionType == 'earn';

  @override
  Widget build(BuildContext context) {
    final color = _isEarn ? AppColors.primary : AppColors.orange;
    final sign = _isEarn ? '+' : '-';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isEarn ? Icons.add_rounded : Icons.remove_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.reason.isEmpty
                      ? 'معاملة نقاط'
                      : transaction.reason,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'الرصيد بعد العملية: ${transaction.balanceAfter}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign${transaction.points}',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeAwardTile extends StatelessWidget {
  final BadgeAwardModel badge;

  const _BadgeAwardTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isRevoked = badge.revokedAt != null;
    final isExpired = !badge.isActive && !isRevoked;
    final Color iconBg;
    final Color iconFg;
    if (isRevoked) {
      iconBg = const Color(0xFFFFEBEE);
      iconFg = AppColors.error;
    } else if (isExpired) {
      iconBg = AppColors.inputBg;
      iconFg = AppColors.textHint;
    } else {
      iconBg = AppColors.purpleLight;
      iconFg = AppColors.purple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.workspace_premium_rounded, color: iconFg, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name.isEmpty ? badge.badgeType : badge.name,
                  style: TextStyle(
                    color: isRevoked || isExpired
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration: isRevoked ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (badge.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    badge.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isRevoked
                  ? AppColors.error.withValues(alpha: 0.1)
                  : isExpired
                      ? AppColors.inputBg
                      : AppColors.purpleLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isRevoked ? 'مُلغى' : isExpired ? 'منتهٍ' : 'نشط',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isRevoked
                    ? AppColors.error
                    : isExpired
                        ? AppColors.textHint
                        : AppColors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCatalogTile extends StatelessWidget {
  final BadgeCatalogItem item;
  final bool earned;

  const _BadgeCatalogTile({required this.item, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
          width: earned ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: earned ? AppColors.primaryLight : AppColors.inputBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: earned ? AppColors.primary : AppColors.textHint,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.isEmpty ? item.badgeType : item.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
                if (item.criteriaThreshold != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'الحد: ${item.criteriaThreshold}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: earned
                  ? AppColors.primaryLight
                  : AppColors.inputBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              earned ? 'مكتسبة ✓' : 'متاحة',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: earned ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
