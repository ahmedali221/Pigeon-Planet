import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../home/model/datasources/points_remote_datasource.dart';
import '../../viewmodel/badges_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class BadgesPage extends StatelessWidget {
  BadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BadgesBloc>()..add(BadgesLoadRequested()),
      child: _BadgesView(),
    );
  }
}

// Alias keeps existing NavigatorPush calls compiling without changes.
typedef SellerBadgesPage = BadgesPage;

class _BadgesView extends StatelessWidget {
  _BadgesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BadgesBloc, BadgesState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: NestedScrollView(
            headerSliverBuilder: (_, _) => [
              SliverAppBar(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                title: Text(
                  state.badges.isNotEmpty
                      ? AppLocalizations.of(context).alawsma(state.badges.length)
                      : AppLocalizations.of(context).badgesTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: AppColors.primary,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 4),
                    child: TextButton.icon(
                      onPressed: () => context
                          .read<BadgesBloc>()
                          .add(BadgesIncludeExpiredToggled()),
                      icon: Icon(
                        state.includeExpired
                            ? Icons.history_toggle_off_rounded
                            : Icons.history_rounded,
                        size: 18,
                        color: state.includeExpired
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      label: Text(
                        state.includeExpired ? AppLocalizations.of(context).activeOnly : AppLocalizations.of(context).previous,
                        style: TextStyle(
                          fontSize: 12,
                          color: state.includeExpired
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh_rounded, size: 20),
                    onPressed: () => context
                        .read<BadgesBloc>()
                        .add(BadgesLoadRequested()),
                  ),
                ],
              ),
            ],
            body: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BadgesState state) {
    if (state.status == BadgesStatus.loading) {
      return Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state.status == BadgesStatus.error) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              SizedBox(height: 16),
              Text(
                state.errorMessage ?? AppLocalizations.of(context).badgesLoadError,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context
                    .read<BadgesBloc>()
                    .add(BadgesLoadRequested()),
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(AppLocalizations.of(context).retry,
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    if (state.badges.isEmpty) {
      return _EmptyBadges();
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          context.read<BadgesBloc>().add(BadgesLoadRequested()),
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: state.badges.length,
        itemBuilder: (context, i) => _BadgeCard(badge: state.badges[i]),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyBadges extends StatelessWidget {
  _EmptyBadges();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.military_tech_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).noBadgesYet,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).completeDealsForBadges,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge card ────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  final BadgeAwardModel badge;

  _BadgeCard({required this.badge});

  static IconData _icon(String type) => switch (type) {
        'first_order' => Icons.shopping_bag_rounded,
        'points_starter' => Icons.stars_rounded,
        'seller_starter' => Icons.storefront_rounded,
        'WELCOME_BUYER' => Icons.waving_hand_rounded,
        'WELCOME_SELLER' => Icons.store_rounded,
        'FIRST_BIDDER' => Icons.gavel_rounded,
        'LAST_MINUTE_FIGHTER' => Icons.timer_rounded,
        'AUCTION_PURCHASE_CONFIRMED' => Icons.emoji_events_rounded,
        'MARKET_PURCHASE_CONFIRMED' => Icons.shopping_cart_checkout_rounded,
        'REVIEWER_BUYER' => Icons.rate_review_rounded,
        'LOYAL_FOLLOWER' => Icons.favorite_rounded,
        'FIRST_AUCTION_PUBLISHED' => Icons.public_rounded,
        'FIRST_MARKET_ITEM_LISTED' => Icons.add_business_rounded,
        'FIRST_AUCTION_SALE_CONFIRMED' => Icons.sell_rounded,
        'FIRST_MARKET_SALE_CONFIRMED' => Icons.point_of_sale_rounded,
        'TRUSTED_BUYER' => Icons.verified_user_rounded,
        'TRUSTED_SELLER' => Icons.verified_rounded,
        _ => Icons.military_tech_rounded,
      };

  static String _shortDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRevoked = badge.revokedAt != null;
    final isExpired = !badge.isActive && !isRevoked;

    final Color borderColor;
    final Color bgColor;
    final Color iconColor;
    if (isRevoked) {
      borderColor = AppColors.error.withValues(alpha: 0.3);
      bgColor = Color(0xFFFFEBEE);
      iconColor = AppColors.error;
    } else if (isExpired) {
      borderColor = AppColors.textHint.withValues(alpha: 0.4);
      bgColor = AppColors.inputBg;
      iconColor = AppColors.textHint;
    } else {
      borderColor = AppColors.primary.withValues(alpha: 0.3);
      bgColor = AppColors.primaryLight;
      iconColor = AppColors.primary;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isRevoked ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status chip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isRevoked
                    ? AppColors.error.withValues(alpha: 0.1)
                    : isExpired
                        ? AppColors.inputBg
                        : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isRevoked ? AppLocalizations.of(context).mlgha : isExpired ? AppLocalizations.of(context).expired : AppLocalizations.of(context).statusActive,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isRevoked
                      ? AppColors.error
                      : isExpired
                          ? AppColors.textHint
                          : AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 10),
            // Icon circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: badge.iconUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        badge.iconUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          _icon(badge.badgeType),
                          size: 28,
                          color: iconColor,
                        ),
                      ),
                    )
                  : Icon(_icon(badge.badgeType), size: 28, color: iconColor),
            ),
            SizedBox(height: 10),
            Text(
              badge.name.isNotEmpty ? badge.name : badge.badgeType,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isRevoked || isExpired
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                decoration: isRevoked ? TextDecoration.lineThrough : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Expiry hint for active temporary badges
            if (badge.expiresAt != null && !isRevoked && !isExpired) ...[
              SizedBox(height: 4),
              Text(
                'ينتهي ${_shortDate(badge.expiresAt!)}',
                style: TextStyle(
                    fontSize: 10, color: AppColors.textHint),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
