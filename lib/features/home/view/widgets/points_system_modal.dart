import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../promotions/model/datasources/promotions_remote_datasource.dart';
import '../../../promotions/viewmodel/buy_with_cashback_bloc.dart';
import '../../model/datasources/points_remote_datasource.dart';
import '../pages/points_history_page.dart';

import '../../../../l10n/app_localizations.dart';
// ── Entry point ───────────────────────────────────────────────────────────────

class PointsSystemModal extends StatelessWidget {
  final int pointsBalance;
  final bool isSeller;

  PointsSystemModal({
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

  _ModalBody({
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
          decoration: BoxDecoration(
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
                _InlineNotice(
                  icon: Icons.info_outline_rounded,
                  text: AppLocalizations.of(context).pointsLoyaltyLoadError,
                ),

              // ── Tab views ───────────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _PointsTab(
                      isLoading: isLoading,
                      transactions: data?.transactions ?? [],
                      isSeller: widget.isSeller,
                    ),
                    _RewardsTab(
                      isLoading: isLoading,
                      badges: data?.badges ?? [],
                      catalog: data?.catalog ?? [],
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

  _ModalHeader({
    required this.tabController,
    required this.pointsBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
            margin: EdgeInsets.only(top: 10, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).pointsSystemTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context).pointsSystemSubtitle,
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
                    child: Icon(
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).currentBalance,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Spacer(),
                  Text(
                    AppLocalizations.of(context).pointsAmount(pointsBalance),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
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
            margin: EdgeInsets.symmetric(horizontal: 16),
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
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: TextStyle(fontSize: 14),
              tabs: [
                Tab(text: AppLocalizations.of(context).pointsTabLabel),
                Tab(text: AppLocalizations.of(context).rewardsTabLabel),
              ],
            ),
          ),
          SizedBox(height: 12),
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

  _BalanceBreakdown({
    required this.totalBalance,
    required this.loyaltyBalance,
    required this.packageBalance,
  });

  @override
  Widget build(BuildContext context) {
    final packagePoints = packageBalance ?? 0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _BalanceRow(
            icon: Icons.account_balance_wallet_rounded,
            label: AppLocalizations.of(context).totalPoints,
            value: totalBalance,
            color: AppColors.primary,
            isStrong: true,
          ),
          Divider(height: 18),
          _BalanceRow(
            icon: Icons.card_giftcard_rounded,
            label: AppLocalizations.of(context).loyaltyPoints,
            value: loyaltyBalance ?? 0,
            color: AppColors.orange,
          ),
          if (packagePoints > 0) ...[
            SizedBox(height: 8),
            _BalanceRow(
              icon: Icons.inventory_2_rounded,
              label: AppLocalizations.of(context).packagePoints,
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

  _BalanceRow({
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
        SizedBox(width: 10),
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
          AppLocalizations.of(context).pointsAmount(value),
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
  final bool isSeller;

  _PointsTab({
    required this.isLoading,
    required this.transactions,
    required this.isSeller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _SectionTitle(icon: '•', label: AppLocalizations.of(context).pointsLog),
        SizedBox(height: 10),
        if (isLoading)
          _LoadingCard()
        else if (transactions.isEmpty)
          _InlineNotice(
            icon: Icons.receipt_long_rounded,
            text: AppLocalizations.of(context).noPointTransactions,
          )
        else
          ...transactions
              .take(5)
              .map((tx) => _TransactionTile(transaction: tx)),

        if (!isLoading && transactions.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PointsHistoryPage(),
                ),
              ),
              icon: Icon(Icons.history_rounded, size: 16),
              label: Text(AppLocalizations.of(context).viewAllTransactions),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 8),
                textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        if (!isSeller) ...[
          SizedBox(height: 8),
          _ConvertCashbackCard(),
        ],

        SizedBox(height: 20),

        // How to earn
        _SectionTitle(icon: '⚡', label: AppLocalizations.of(context).howEarnPoints),
        SizedBox(height: 10),
        ..._earnItems(AppLocalizations.of(context)).map((e) => _EarnTile(item: e)),

        SizedBox(height: 20),

        // Points value table
        _SectionTitle(icon: '📊', label: AppLocalizations.of(context).pointsValue),
        SizedBox(height: 10),
        _PointsValueTable(),

        SizedBox(height: 20),

        // Note
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.orangeLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).pointsExpiryNote,
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

// earn items data
List<_EarnItem> _earnItems(AppLocalizations l) => [
  _EarnItem(
    icon: Icons.gavel_rounded,
    color: AppColors.primary,
    colorBg: AppColors.primaryLight,
    title: l.earnCompleteSalePurchase,
    subtitle: l.earnCompleteSalePurchaseSub,
    points: 100,
  ),
  _EarnItem(
    icon: Icons.bolt_rounded,
    color: AppColors.orange,
    colorBg: AppColors.orangeLight,
    title: l.earnPayOnTime,
    subtitle: l.earnPayOnTimeSub,
    points: 50,
  ),
  _EarnItem(
    icon: Icons.star_rounded,
    color: AppColors.orange,
    colorBg: AppColors.orangeLight,
    title: l.earnFiveStarRating,
    subtitle: l.earnFiveStarRatingSub,
    points: 30,
  ),
  _EarnItem(
    icon: Icons.person_add_rounded,
    color: AppColors.purple,
    colorBg: AppColors.purpleLight,
    title: l.earnInviteFriend,
    subtitle: l.earnInviteFriendSub,
    points: 30,
  ),
  _EarnItem(
    icon: Icons.badge_rounded,
    color: AppColors.blue,
    colorBg: AppColors.blueLight,
    title: l.earnAddDigitalId,
    subtitle: l.earnAddDigitalIdSub,
    points: 20,
  ),
  _EarnItem(
    icon: Icons.share_rounded,
    color: AppColors.primary,
    colorBg: AppColors.primaryLight,
    title: l.earnShareAuction,
    subtitle: l.earnShareAuctionSub,
    points: 10,
  ),
  _EarnItem(
    icon: Icons.login_rounded,
    color: AppColors.textSecondary,
    colorBg: AppColors.inputBg,
    title: l.earnDailyLogin,
    subtitle: l.earnDailyLoginSub,
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
  _EarnItem({
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
  _EarnTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // points badge (leftmost)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+${item.points}',
                  style: TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 3),
                Icon(
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
  _PointsValueTable();

  static List<(int, String)> _rows(AppLocalizations l) => [
    (50, l.pointsValueDiscountPublish5),
    (100, l.pointsValueDiscountDeal10),
    (200, l.pointsValueFreeWeek),
    (500, l.pointsValueAdUpgrade2),
    (750, l.pointsValueTrustedSellerBadge),
    (1000, l.pointsValueFreeMonth),
    (2500, l.pointsValueHomepageFeaturedAd),
    (5000, l.pointsValueVipThreeMonths),
  ];

  @override
  Widget build(BuildContext context) {
    final rows = _rows(AppLocalizations.of(context));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final (pts, label) = rows[i];
          final isLast = i == rows.length - 1;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    // points (rightmost)
                    Container(
                      width: 64,
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: _milestoneColor(pts).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monetization_on_rounded,
                            color: AppColors.orange,
                            size: 13,
                          ),
                          SizedBox(width: 3),
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
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 13,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, indent: 14, endIndent: 14),
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

  _RewardsTab({
    required this.isLoading,
    required this.badges,
    required this.catalog,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _SectionTitle(icon: '•', label: AppLocalizations.of(context).myBadgesSection),
        SizedBox(height: 10),
        if (isLoading)
          _LoadingCard()
        else if (badges.isEmpty)
          _InlineNotice(
            icon: Icons.workspace_premium_rounded,
            text: AppLocalizations.of(context).noEarnedBadges,
          )
        else
          ...badges.take(5).map((badge) => _BadgeAwardTile(badge: badge)),

        SizedBox(height: 20),

        // Badge catalog from backend
        if (!isLoading && catalog.isNotEmpty) ...[
          _SectionTitle(icon: '🏅', label: AppLocalizations.of(context).availableBadges),
          SizedBox(height: 10),
          ...catalog.map((item) => _BadgeCatalogTile(
                item: item,
                earned: badges.any((b) => b.badgeType == item.badgeType),
              )),
          SizedBox(height: 20),
        ],

        // How to redeem
        _SectionTitle(icon: '🎁', label: AppLocalizations.of(context).howGetReward),
        SizedBox(height: 10),
        _HowToRedeemCard(),

        SizedBox(height: 20),

        // Rewards catalogue
        _SectionTitle(icon: '🏆', label: AppLocalizations.of(context).availablePrizes),
        SizedBox(height: 10),
        ..._rewardCatalogue(AppLocalizations.of(context)).map((r) => _RewardCard(reward: r)),

        SizedBox(height: 20),

        // Tiers
        _SectionTitle(icon: '⭐', label: AppLocalizations.of(context).membershipLevels),
        SizedBox(height: 10),
        _TiersCard(),

        SizedBox(height: 16),
      ],
    );
  }
}

List<_Reward> _rewardCatalogue(AppLocalizations l) => [
  _Reward(
    emoji: '🎟️',
    title: l.rewardAuctionFeeDiscount,
    subtitle: l.rewardAuctionFeeDiscountSub,
    cost: 100,
    category: l.rewardDiscountsCategory,
    categoryColor: AppColors.primary,
  ),
  _Reward(
    emoji: '📦',
    title: l.rewardFreeWeeklySubscription,
    subtitle: l.rewardFreeWeeklySubscriptionSub,
    cost: 200,
    category: l.rewardSubscriptionsCategory,
    categoryColor: AppColors.blue,
  ),
  _Reward(
    emoji: '🔝',
    title: l.rewardAdUpgrade,
    subtitle: l.rewardAdUpgradeSub,
    cost: 500,
    category: l.rewardPromotionCategory,
    categoryColor: AppColors.orange,
  ),
  _Reward(
    emoji: '✅',
    title: l.rewardTrustedSellerBadge,
    subtitle: l.rewardTrustedSellerBadgeSub,
    cost: 750,
    category: l.rewardFeaturesCategory,
    categoryColor: AppColors.purple,
  ),
  _Reward(
    emoji: '🌟',
    title: l.rewardFreeMonthlySubscription,
    subtitle: l.rewardFreeMonthlySubscriptionSub,
    cost: 1000,
    category: l.rewardSubscriptionsCategory,
    categoryColor: AppColors.blue,
  ),
  _Reward(
    emoji: '📣',
    title: l.rewardFeaturedHomepageAd,
    subtitle: l.rewardFeaturedHomepageAdSub,
    cost: 2500,
    category: l.rewardPromotionCategory,
    categoryColor: AppColors.orange,
  ),
  _Reward(
    emoji: '👑',
    title: l.rewardVipMembership,
    subtitle: l.rewardVipMembershipSub,
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
  _Reward({
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
  _RewardCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
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
                child: Text(reward.emoji, style: TextStyle(fontSize: 24)),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reward.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(
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
                  SizedBox(height: 3),
                  Text(
                    reward.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  // cost + redeem button
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on_rounded,
                        color: AppColors.orange,
                        size: 14,
                      ),
                      SizedBox(width: 3),
                      Text(
                        AppLocalizations.of(context).pointsAmount(reward.cost),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () => _showComingSoon(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryDark,
                                AppColors.primary,
                              ],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppLocalizations.of(context).redeem,
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
      SnackBar(
        content: Text(AppLocalizations.of(context).pointsRedemptionComingSoon),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HowToRedeemCard extends StatelessWidget {
  _HowToRedeemCard();

  static List<({IconData icon, Color color, String text})> _steps(AppLocalizations l) => [
    (
      icon: Icons.monetization_on_rounded,
      color: AppColors.orange,
      text: l.howRedeemEarnPoints,
    ),
    (
      icon: Icons.search_rounded,
      color: AppColors.blue,
      text: l.howRedeemChooseReward,
    ),
    (
      icon: Icons.touch_app_rounded,
      color: AppColors.primary,
      text: l.howRedeemTapRedeem,
    ),
    (
      icon: Icons.check_circle_rounded,
      color: AppColors.purple,
      text: l.howRedeemRewardAppears,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(_steps(AppLocalizations.of(context)).length, (i) {
          final s = _steps(AppLocalizations.of(context))[i];
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
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
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        s.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
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
  _TiersCard();

  static List<({String emoji, String name, String range, Color color, Color bg})> _tiers(AppLocalizations l) => [
    (
      emoji: '🥉',
      name: l.tierBronze,
      range: l.tierBronzeRange,
      color: Color(0xFFCD7F32),
      bg: Color(0xFFFFF8F0),
    ),
    (
      emoji: '🥈',
      name: l.tierSilver,
      range: l.tierSilverRange,
      color: Color(0xFF9E9E9E),
      bg: Color(0xFFF5F5F5),
    ),
    (
      emoji: '🥇',
      name: l.tierGold,
      range: l.tierGoldRange,
      color: Color(0xFFD4A017),
      bg: Color(0xFFFFFDE7),
    ),
    (
      emoji: '💎',
      name: 'VIP',
      range: l.tierVipRange,
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
        children: List.generate(_tiers(AppLocalizations.of(context)).length, (i) {
          final t = _tiers(AppLocalizations.of(context))[i];
          final isLast = i == _tiers(AppLocalizations.of(context)).length - 1;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
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
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
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
                            style: TextStyle(
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
              if (!isLast) Divider(height: 1, indent: 14, endIndent: 14),
            ],
          );
        }),
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
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

  _InlineNotice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
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

// ── Convert Cashback Card (customer-only) ─────────────────────────────────────

class _ConvertCashbackCard extends StatelessWidget {
  _ConvertCashbackCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _BuyWithCashbackSheet(),
      ),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.currency_exchange_rounded,
                color: AppColors.orange,
                size: 22,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).convertCashbackToPoints,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context).cashbackConversionRate,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Buy With Cashback Sheet ───────────────────────────────────────────────────

class _BuyWithCashbackSheet extends StatefulWidget {
  _BuyWithCashbackSheet();

  @override
  State<_BuyWithCashbackSheet> createState() => _BuyWithCashbackSheetState();
}

class _BuyWithCashbackSheetState extends State<_BuyWithCashbackSheet> {
  final _ctrl = TextEditingController();
  late final Future<double> _balanceFuture;

  @override
  void initState() {
    super.initState();
    _balanceFuture = sl<PromotionsRemoteDataSource>().fetchCashbackBalance();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BuyWithCashbackBloc>(),
      child: BlocConsumer<BuyWithCashbackBloc, BuyWithCashbackState>(
        listener: (context, state) {
          if (state.status == BuyWithCashbackStatus.success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).cashbackConversionSuccess(state.pointsAwarded ?? 0),
                ),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.status == BuyWithCashbackStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? AppLocalizations.of(context).tryAgainError),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == BuyWithCashbackStatus.loading;
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context).convertCashbackToPoints,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).cashbackConversionRate,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16),
                    FutureBuilder<double>(
                      future: _balanceFuture,
                      builder: (_, snap) {
                        final balance = snap.data;
                        return Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.orange,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                AppLocalizations.of(context).cashbackBalanceLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Spacer(),
                              if (snap.connectionState ==
                                  ConnectionState.waiting)
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              else
                                Text(
                                  balance != null
                                      ? balance.toStringAsFixed(2)
                                      : '—',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _ctrl,
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).cashbackAmountHint,
                        hintStyle: TextStyle(
                            color: AppColors.textHint, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppColors.primary),
                        ),
                        prefixIcon: Icon(Icons.monetization_on_rounded,
                            color: AppColors.orange, size: 20),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                final amount =
                                    double.tryParse(_ctrl.text.trim()) ?? 0;
                                if (amount <= 0) return;
                                context.read<BuyWithCashbackBloc>().add(
                                      BuyWithCashbackRequested(amount),
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context).convertNow,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final PointTransactionModel transaction;

  _TransactionTile({required this.transaction});

  bool get _isEarn => transaction.transactionType == 'earn';

  @override
  Widget build(BuildContext context) {
    final color = _isEarn ? AppColors.primary : AppColors.orange;
    final sign = _isEarn ? '+' : '-';
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
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
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.reason.isEmpty
                      ? AppLocalizations.of(context).pointsTransactionFallback
                      : transaction.reason,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).balanceAfterTransaction(transaction.balanceAfter),
                  style: TextStyle(
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

  _BadgeAwardTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isRevoked = badge.revokedAt != null;
    final isExpired = !badge.isActive && !isRevoked;
    final Color iconBg;
    final Color iconFg;
    if (isRevoked) {
      iconBg = Color(0xFFFFEBEE);
      iconFg = AppColors.error;
    } else if (isExpired) {
      iconBg = AppColors.inputBg;
      iconFg = AppColors.textHint;
    } else {
      iconBg = AppColors.purpleLight;
      iconFg = AppColors.purple;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
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
          SizedBox(width: 10),
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
                  SizedBox(height: 2),
                  Text(
                    badge.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isRevoked
                  ? AppColors.error.withValues(alpha: 0.1)
                  : isExpired
                      ? AppColors.inputBg
                      : AppColors.purpleLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isRevoked ? AppLocalizations.of(context).revoked : isExpired ? AppLocalizations.of(context).expired : AppLocalizations.of(context).statusActive,
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

  _BadgeCatalogTile({required this.item, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
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
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.isEmpty ? item.badgeType : item.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
                if (item.criteriaThreshold != null) ...[
                  SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context).thresholdLabel(item.criteriaThreshold ?? 0),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: earned
                  ? AppColors.primaryLight
                  : AppColors.inputBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              earned ? AppLocalizations.of(context).earnedBadge : AppLocalizations.of(context).available,
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
  _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: 16)),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
