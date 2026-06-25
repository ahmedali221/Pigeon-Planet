import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../../../core/di/injection.dart';
import '../../model/cashback_offer_model.dart';
import '../../model/discount_offer_model.dart';
import '../../model/user_promotion_grant_model.dart';
import '../../viewmodel/promotions_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class PromotionsOffersPage extends StatelessWidget {
  PromotionsOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PromotionsBloc>()..add(PromotionsOffersRequested()),
      child: _PromotionsOffersView(),
    );
  }
}

class _PromotionsOffersView extends StatelessWidget {
  _PromotionsOffersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PPWAppBar(
        title: AppLocalizations.of(context).alarwdWaltkhfydat,
        actions: [
          BlocBuilder<PromotionsBloc, PromotionsState>(
            buildWhen: (prev, curr) => prev.offersLoading != curr.offersLoading,
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: state.offersLoading
                  ? null
                  : () => context
                      .read<PromotionsBloc>()
                      .add(PromotionsOffersRequested()),
            ),
          ),
        ],
      ),
      body: BlocBuilder<PromotionsBloc, PromotionsState>(
        buildWhen: (prev, curr) =>
            prev.offersLoading != curr.offersLoading ||
            prev.discountOffers != curr.discountOffers ||
            prev.cashbackOffers != curr.cashbackOffers ||
            prev.grants != curr.grants,
        builder: (context, state) {
          if (state.offersLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final hasAny = state.discountOffers.isNotEmpty ||
              state.cashbackOffers.isNotEmpty ||
              state.grants.isNotEmpty;

          if (!hasAny) {
            return _EmptyOffersState();
          }

          return CustomScrollView(
            slivers: [
              if (state.grants.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.card_giftcard_rounded,
                  title: AppLocalizations.of(context).arwdkAlkhasa,
                  color: AppColors.primary,
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        if (i == state.grants.length) {
                          return _GrantsLoadMore(
                            hasMore: state.hasMoreGrants,
                            loading: state.loadingMoreGrants,
                          );
                        }
                        return _GrantTile(grant: state.grants[i]);
                      },
                      childCount: state.grants.length + 1,
                    ),
                  ),
                ),
              ],
              if (state.discountOffers.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.local_offer_rounded,
                  title: AppLocalizations.of(context).arwdAltkhfyd,
                  color: Color(0xFF6B4FBB),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) =>
                          _DiscountOfferTile(offer: state.discountOffers[i]),
                      childCount: state.discountOffers.length,
                    ),
                  ),
                ),
              ],
              if (state.cashbackOffers.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.account_balance_wallet_rounded,
                  title: AppLocalizations.of(context).arwdAlkashBak,
                  color: Color(0xFF2B8A3E),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) =>
                          _CashbackOfferTile(offer: state.cashbackOffers[i]),
                      childCount: state.cashbackOffers.length,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrantTile extends StatelessWidget {
  final UserPromotionGrantModel grant;
  _GrantTile({required this.grant});

  @override
  Widget build(BuildContext context) {
    final expiresAt = grant.expiresAt != null
        ? DateTime.tryParse(grant.expiresAt!)
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.card_giftcard_rounded,
                  color: AppColors.primary, size: 22),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grant.displayTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (expiresAt != null) ...[
                    SizedBox(height: 3),
                    Text(
                      'ينتهي: ${expiresAt.year}-${expiresAt.month.toString().padLeft(2, '0')}-${expiresAt.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textHint),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                grant.grantType == 'discount' ? AppLocalizations.of(context).tkhfyd : AppLocalizations.of(context).kashBak,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrantsLoadMore extends StatelessWidget {
  final bool hasMore;
  final bool loading;

  _GrantsLoadMore({required this.hasMore, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (!hasMore) return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Center(
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: () => context
                    .read<PromotionsBloc>()
                    .add(PromotionsGrantsLoadMore()),
                child: Text(AppLocalizations.of(context).loadMore),
              ),
      ),
    );
  }
}

class _DiscountOfferTile extends StatelessWidget {
  final DiscountOfferModel offer;
  _DiscountOfferTile({required this.offer});

  @override
  Widget build(BuildContext context) {
    return _OfferCard(
      icon: Icons.local_offer_rounded,
      iconColor: Color(0xFF6B4FBB),
      bgColor: Color(0xFFF3EFFF),
      title: offer.title,
      valueBadge: offer.displayValue,
      subtitle: offer.description.isNotEmpty ? offer.description : null,
      footer: offer.displayTarget,
      minimumOrder: double.tryParse(offer.minimumOrderPrice) ?? 0,
    );
  }
}

class _CashbackOfferTile extends StatelessWidget {
  final CashbackOfferModel offer;
  _CashbackOfferTile({required this.offer});

  @override
  Widget build(BuildContext context) {
    return _OfferCard(
      icon: Icons.account_balance_wallet_rounded,
      iconColor: Color(0xFF2B8A3E),
      bgColor: Color(0xFFEBF7ED),
      title: offer.title,
      valueBadge: offer.displayValue,
      subtitle: offer.description.isNotEmpty ? offer.description : null,
      footer: offer.displayTarget,
      minimumOrder: double.tryParse(offer.minimumOrderPrice) ?? 0,
    );
  }
}

class _OfferCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String valueBadge;
  final String? subtitle;
  final String footer;
  final double minimumOrder;

  _OfferCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.valueBadge,
    this.subtitle,
    required this.footer,
    required this.minimumOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          valueBadge,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        footer,
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textHint),
                      ),
                      if (minimumOrder > 0) ...[
                        Text(
                          '  •  ',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                        ),
                        Text(
                          'حد أدنى ${minimumOrder.toStringAsFixed(0)} ج.م',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                        ),
                      ],
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
}

class _EmptyOffersState extends StatelessWidget {
  _EmptyOffersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_offer_outlined,
                color: AppColors.primary, size: 36),
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد عروض متاحة الآن',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
          SizedBox(height: 8),
          Text(
            'تابعنا للحصول على أحدث العروض والتخفيضات',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
