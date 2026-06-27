import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/shell_scaffold.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../../cart/view/pages/cart_page.dart';
import '../../../cart/viewmodel/cart_bloc.dart';
import '../../../seller_products/view/pages/seller_products_page.dart';
import '../../model/cashback_offer_model.dart';
import '../../model/discount_offer_model.dart';
import '../../model/product_model.dart';
import '../../viewmodel/market_bloc.dart';
import '../widgets/market_category_tile.dart';
import 'product_detail_page.dart';
import 'products_page.dart';

import '../../../../l10n/app_localizations.dart';
class MarketPage extends StatelessWidget {
  MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isSeller = authState is AuthSuccess ? authState.user.isSeller : false;

    if (isSeller) return SellerProductsPage();

    return BlocProvider(
      create: (_) => sl<MarketBloc>()..add(MarketStarted()),
      child: _MarketView(),
    );
  }
}

class _MarketView extends StatelessWidget {
  _MarketView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          // ── Green header ──────────────────────────────────────────────────
          _MarketHeader(),

          // ── Search bar ────────────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).marketSearchHint,
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (q) =>
                    context.read<MarketBloc>().add(MarketSearchChanged(q)),
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<MarketBloc, MarketState>(
              builder: (context, state) {
                if (state.status == MarketStatus.initial ||
                    state.status == MarketStatus.loading) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final categories = state.searchQuery.isEmpty
                    ? state.categories
                    : state.categories
                          .where((c) => c.name.contains(state.searchQuery))
                          .toList();

                return ListView(
                  padding: EdgeInsets.only(top: 16, bottom: 24),
                  children: [
                    // ── Stats bar ─────────────────────────────────────────
                    _StatsBar(totalProducts: state.totalProductsCount),
                    SizedBox(height: 12),

                    // ── Active promotions ─────────────────────────────────
                    if (state.discountOffers.isNotEmpty ||
                        state.cashbackOffers.isNotEmpty) ...[
                      _PromotionsStrip(
                        discountOffers: state.discountOffers,
                        cashbackOffers: state.cashbackOffers,
                      ),
                      SizedBox(height: 12),
                    ],

                    // ── Quality banner ────────────────────────────────────
                    _QualityBanner(),
                    SizedBox(height: 16),

                    // ── Personalized feed ─────────────────────────────────
                    if (state.feedProducts.isNotEmpty) ...[
                      _FeedSection(
                        products: state.feedProducts,
                        hasMore: state.feedHasMore,
                        isLoading: state.feedLoading,
                        onLoadMore: () => context
                            .read<MarketBloc>()
                            .add(MarketFeedLoadMoreRequested()),
                      ),
                      SizedBox(height: 16),
                    ],

                    // ── Categories ────────────────────────────────────────
                    ...categories.map(
                      (cat) => MarketCategoryTile(
                        category: cat,
                        onTap: () {
                          context.read<MarketBloc>().add(
                            MarketCategorySelected(cat),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(
                                    value: context.read<MarketBloc>(),
                                  ),
                                  BlocProvider.value(
                                    value: context.read<CartBloc>(),
                                  ),
                                ],
                                child: ProductsPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Green header ──────────────────────────────────────────────────────────────
class _MarketHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final authState = context.read<AuthBloc>().state;
    final isSeller = authState is AuthSuccess
        ? authState.user.isSeller
        : false;

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: topPadding + 12,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          ShellBackButton(color: Colors.white),
          BlocBuilder<CartBloc, CartState>(
            buildWhen: (p, c) => p.itemsCount != c.itemsCount,
            builder: (context, state) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<CartBloc>(),
                      child: CartPage(),
                    ),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                  if (state.itemsCount > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${state.itemsCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context).market,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isSeller)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SellerProductsPage()),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_rounded, color: Colors.white, size: 15),
                    SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context).myProducts,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(width: 26),
        ],
      ),
    );
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final int totalProducts;
  _StatsBar({required this.totalProducts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text('🚚', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).homeDelivery,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text('📦', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 4),
                  Text(
                    '$totalProducts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).availableProduct,
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quality banner ────────────────────────────────────────────────────────────
class _QualityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.verified_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).allProductsHighQuality,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).certifiedOriginalProducts,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Promotions strip ──────────────────────────────────────────────────────────
class _PromotionsStrip extends StatelessWidget {
  final List<DiscountOfferModel> discountOffers;
  final List<CashbackOfferModel> cashbackOffers;

  _PromotionsStrip({
    required this.discountOffers,
    required this.cashbackOffers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 16),
          child: Text(
            AppLocalizations.of(context).activeOffers,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsetsDirectional.only(start: 16, end: 8),
            children: [
              ...discountOffers.map(
                (o) => _OfferChip(
                  label: o.label(
                    AppLocalizations.of(context).discount,
                    AppLocalizations.of(context).egpCurrency,
                  ),
                  color: AppColors.orange,
                  icon: '🎁',
                ),
              ),
              ...cashbackOffers.map(
                (o) => _OfferChip(
                  label: o.label(
                    AppLocalizations.of(context).cashback,
                    AppLocalizations.of(context).egpCurrency,
                  ),
                  color: AppColors.primary,
                  icon: '💰',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OfferChip extends StatelessWidget {
  final String label;
  final Color color;
  final String icon;

  _OfferChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.only(end: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: 14)),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Personalized feed section ─────────────────────────────────────────────────
class _FeedSection extends StatelessWidget {
  final List<ProductModel> products;
  final bool hasMore;
  final bool isLoading;
  final VoidCallback onLoadMore;

  _FeedSection({
    required this.products,
    required this.hasMore,
    required this.isLoading,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 16),
          child: Text(
            AppLocalizations.of(context).suggestedForYou,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: MediaQuery.sizeOf(context).width * 0.42 * 1.42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsetsDirectional.only(start: 16, end: 8),
            itemCount: products.length + (hasMore ? 1 : 0),
            separatorBuilder: (_, _) => SizedBox(width: 10),
            itemBuilder: (context, i) {
              if (i == products.length) {
                return isLoading
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: onLoadMore,
                        child: Container(
                          width: 72,
                          margin: EdgeInsetsDirectional.only(end: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(height: 6),
                              Text(
                                AppLocalizations.of(context).more,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              }
              return _FeedProductCard(
                product: products[i],
                onTap: () {
                  context.read<MarketBloc>().add(
                    MarketProductOpened(products[i]),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<MarketBloc>(),
                        child: BlocProvider.value(
                          value: context.read<CartBloc>(),
                          child: ProductDetailPage(),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeedProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  _FeedProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFollowing = product.source == 'following';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).width * 0.42 * 0.84,
                  child: product.thumbnailUrl != null
                      ? Image.network(
                          product.thumbnailUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.primaryLight,
                            child: Icon(
                              Icons.storefront_outlined,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primaryLight,
                          child: Icon(
                            Icons.storefront_outlined,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                ),
                if (isFollowing)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppLocalizations.of(context).followedAlt,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Text(
                    AppLocalizations.of(context).priceEgpFormat(
                      product.price.toStringAsFixed(0),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
